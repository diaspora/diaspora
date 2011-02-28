#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/diaspora/user')
require File.join(Rails.root, 'lib/salmon/salmon')
require File.join(Rails.root, 'lib/postzord/dispatch')
require 'rest-client'

class User < ActiveRecord::Base
  include Diaspora::UserModules
  include Encryptor::Private

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable

  before_validation :strip_and_downcase_username, :on => :create
  before_validation :set_current_language, :on => :create

  validates_presence_of :username
  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :maximum => 32
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES

  validates_presence_of :person, :unless => proc {|user| user.invitation_token.present?}
  validates_associated :person

  has_one :person, :foreign_key => :owner_id
  delegate :public_key, :posts, :owns?, :diaspora_handle, :name, :public_url, :profile, :first_name, :last_name, :to => :person

  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id
  has_many :aspects
  has_many :aspect_memberships, :through => :aspects
  has_many :contacts
  has_many :contact_people, :through => :contacts, :source => :person
  has_many :services

  before_destroy :disconnect_everyone, :remove_person
  before_save do
    person.save if person && person.changed?
  end

  attr_accessible :getting_started, :password, :password_confirmation, :language, :disable_mail

  def strip_and_downcase_username
    if username.present?
      username.strip!
      username.downcase!
    end
  end

  def set_current_language
    self.language = I18n.locale.to_s if self.language.blank?
  end

  def self.find_for_authentication(conditions={})
    conditions[:username] = conditions[:username].downcase
    if conditions[:username] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i # email regex
      conditions[:email] = conditions.delete(:username)
    end
    super(conditions)
  end

  ######### Aspects ######################
  def drop_aspect(aspect)
      aspect.destroy
  end

  def move_contact(person, to_aspect, from_aspect)
    return true if to_aspect == from_aspect
    contact = contact_for(person)
    if add_contact_to_aspect(contact, to_aspect)
      membership = contact ? contact.aspect_memberships.where(:aspect_id => from_aspect.id).first : nil
      return ( membership && membership.destroy )
    else
      false
    end
  end

  def add_contact_to_aspect(contact, aspect)
    return true if contact.aspect_memberships.where(:aspect_id => aspect.id).count > 0
    contact.aspect_memberships.create!(:aspect => aspect)
  end

  ######## Posting ########
  def build_post(class_name, opts = {})
    opts[:person] = self.person
    opts[:diaspora_handle] = opts[:person].diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.diaspora_initialize(opts)
  end

  def dispatch_post(post, opts = {})
    mailman = Postzord::Dispatch.new(self, post)
    mailman.post(opts)
  end

  def update_post(post, post_hash = {})
    if self.owns? post
      post.update_attributes(post_hash)
      Postzord::Dispatch.new(self, post).post
    end
  end

  def add_post_to_aspects(post)
    Rails.logger.debug("event=add_post_to_aspects user_id=#{self.id} post_id=#{post.id}")
    add_to_streams(post, self.aspects_with_person(post.person))
    post
  end

  def add_to_streams(post, aspects_to_insert)
    post.socket_to_user(self, :aspect_ids => aspects_to_insert.map{|x| x.id}) if post.respond_to? :socket_to_user
    aspects_to_insert.each do |aspect|
      aspect.posts << post
    end
  end

  def aspects_from_ids(aspect_ids)
    if aspect_ids == "all" || aspect_ids == :all
      self.aspects
    else
      aspects.where(:id => aspect_ids)
    end
  end

  def salmon(post)
    created_salmon = Salmon::SalmonSlap.create(self, post.to_diaspora_xml)
    created_salmon
  end

  ######## Commenting  ########
  def build_comment(text, options = {})
    comment = Comment.new(:person_id => self.person.id,
                          :text => text,
                          :post => options[:on])
    comment.set_guid
    #sign comment as commenter
    comment.creator_signature = comment.sign_with_key(self.encryption_key)

    if !comment.post_id.blank? && person.owns?(comment.post)
      #sign comment as post owner
      comment.post_creator_signature = comment.sign_with_key(self.encryption_key)
    end

    comment
  end

  def dispatch_comment(comment)
    mailman = Postzord::Dispatch.new(self, comment)
    mailman.post
  end

  ######### Mailer #######################
  def mail(job, *args)
    unless self.disable_mail
      Resque.enqueue(job, *args)
    end
  end

  ######### Posts and Such ###############
  def retract(post)
    aspects = post.aspects

    retraction = Retraction.for(post)
    post.unsocket_from_user(self, :aspect_ids => aspects.map { |a| a.id.to_s }) if post.respond_to? :unsocket_from_user
    mailman = Postzord::Dispatch.new(self, retraction)
    mailman.post

    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    if photo = params.delete(:photo)
      photo.update_attributes(:pending => false) if photo.pending
      params[:image_url] = photo.url(:thumb_large)
      params[:image_url_medium] = photo.url(:thumb_medium)
      params[:image_url_small] = photo.url(:thumb_small)
    end
    if self.person.profile.update_attributes(params)
      Postzord::Dispatch.new(self, profile).post
      true
    else
      false
    end
  end

  ###Invitations############
  def invite_user(aspect_id, service, identifier, invite_message = "")
    aspect = aspects.find(aspect_id)
    if aspect
      Invitation.invite(:service => service,
                        :identifier => identifier,
                        :from => self,
                        :into => aspect,
                        :message => invite_message)
    else
      false
    end
  end

  def accept_invitation!(opts = {})
    log_string = "event=invitation_accepted username=#{opts[:username]} uid=#{self.id} "
    log_string << "inviter=#{invitations_to_me.first.sender.diaspora_handle} " if invitations_to_me.first
    begin
      if self.invited?
        self.setup(opts)
        self.invitation_token = nil
        self.password              = opts[:password]
        self.password_confirmation = opts[:password_confirmation]
        self.save!
        invitations_to_me.each{|invitation| invitation.to_request!}
        log_string << "success"
        Rails.logger.info log_string

        self.reload # Because to_request adds a request and saves elsewhere
        self
      end
    rescue Exception => e
      log_string << "failure"
      Rails.logger.info log_string
      raise e
    end
  end

  ###Helpers############
  def self.build(opts = {})
    u = User.new(opts)
    u.setup(opts)
    u
  end

  def setup(opts)
    self.username = opts[:username]
    self.email = opts[:email]
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0

    opts[:person] ||= {}
    unless opts[:person][:profile].is_a?(Profile)
      opts[:person][:profile] ||= Profile.new
      opts[:person][:profile] = Profile.new(opts[:person][:profile])
    end

    self.person = Person.new(opts[:person])
    self.person.diaspora_handle = "#{opts[:username]}@#{AppConfig[:pod_uri].host}"
    self.person.url = AppConfig[:pod_url]


    self.serialized_private_key = User.generate_key if self.serialized_private_key.blank?
    self.person.serialized_public_key = OpenSSL::PKey::RSA.new(self.serialized_private_key).public_key

    self
  end

  def seed_aspects
    self.aspects.create(:name => I18n.t('aspects.seed.family'))
    self.aspects.create(:name => I18n.t('aspects.seed.work'))
  end

  def self.generate_key
    key_size = (Rails.env == 'test' ? 512 : 4096)
    OpenSSL::PKey::RSA::generate key_size
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(serialized_private_key)
  end

  protected

  def remove_person
    self.person.destroy
  end

  def disconnect_everyone
    Contact.unscoped.where(:user_id => self.id).each { |contact|
      if contact.person.owner_id
        contact.person.owner.disconnected_by self.person
        remove_contact(contact)
      else
        self.disconnect contact
      end
    }
    self.aspects.delete_all
  end
end
