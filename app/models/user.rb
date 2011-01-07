#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/diaspora/user')
require File.join(Rails.root, 'lib/salmon/salmon')
require File.join(Rails.root, 'lib/postzord/dispatch')
require 'rest-client'

class User
  include MongoMapper::Document
  include Diaspora::UserModules
  include Encryptor::Private

  plugin MongoMapper::Devise

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable

  key :username
  key :serialized_private_key, String
  key :invites, Integer, :default => 5
  key :invitation_token, String
  key :invitation_sent_at, DateTime
  key :visible_post_ids, Array, :typecast => 'ObjectId'
  key :visible_person_ids, Array, :typecast => 'ObjectId'

  key :getting_started, Boolean, :default => true
  key :disable_mail, Boolean, :default => false

  key :email, String
  key :language, String

  before_validation :strip_and_downcase_username, :on => :create
  before_validation :set_current_language, :on => :create

  validates_presence_of :username
  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :maximum => 32
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES

  validates_presence_of :person, :unless => proc {|user| user.invitation_token.present?}
  validates_associated :person

  one :person, :class => Person, :foreign_key => :owner_id

  many :invitations_from_me, :class => Invitation, :foreign_key => :from_id
  many :invitations_to_me, :class => Invitation, :foreign_key => :to_id
  many :contacts, :class => Contact, :foreign_key => :user_id
  many :visible_people, :in => :visible_person_ids, :class => Person # One of these needs to go
  many :raw_visible_posts, :in => :visible_post_ids, :class => Post
  many :aspects, :class => Aspect, :dependent => :destroy

  many :services, :class => Service
  timestamps!

  before_destroy :disconnect_everyone, :remove_person
  before_save do
    person.save if person
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
    super
  end

  ######## Making things work ########

  def method_missing(method, *args)
    self.person.send(method, *args) if self.person
  end

  ######### Aspects ######################
  def drop_aspect(aspect)
    if aspect.contacts.count == 0
      aspect.destroy
    else
      raise "Aspect not empty"
    end
  end

  def move_contact(person, to_aspect, from_aspect)
    contact = contact_for(person)
    if to_aspect == from_aspect
      true
    elsif add_contact_to_aspect(contact, to_aspect)
      delete_person_from_aspect(person.id, from_aspect.id)
    end
  end

  def salmon(post)
    created_salmon = Salmon::SalmonSlap.create(self, post.to_diaspora_xml)
    created_salmon
  end

  def add_contact_to_aspect(contact, aspect)
    return true if contact.aspect_ids.include?(aspect.id)
    contact.aspects << aspect
    contact.save!
  end

  def delete_person_from_aspect(person_id, aspect_id, opts = {})
    aspect = Aspect.find(aspect_id)
    raise "Can not delete a person from an aspect you do not own" unless aspect.user == self
    contact = contact_for Person.find(person_id)

    if opts[:force] || contact.aspect_ids.count > 1
      contact.aspect_ids.delete aspect.id
      contact.save!
      aspect.save!
    else
      raise "Can not delete a person from last aspect"
    end
  end

  ######## Posting ########
  def build_post(class_name, opts = {})
    opts[:person] = self.person
    opts[:diaspora_handle] = opts[:person].diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.instantiate(opts)
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

  def add_to_streams(post, aspect_ids)
    self.raw_visible_posts << post
    self.save

    post.socket_to_uid(self, :aspect_ids => aspect_ids) if post.respond_to? :socket_to_uid
    target_aspects = aspects_from_ids(aspect_ids)
    target_aspects.each do |aspect|
      aspect.posts << post
      aspect.save
    end
  end

  def aspects_from_ids(aspect_ids)
    if aspect_ids == "all" || aspect_ids == :all
      self.aspects
    else
      if aspect_ids.respond_to? :to_id
        aspect_ids = [aspect_ids]
      end
      aspect_ids.map!{ |x| x.to_id }
      aspects.all(:id.in => aspect_ids)
    end
  end

  ######## Commenting  ########
  def build_comment(text, options = {})
    comment = Comment.new(:person_id => self.person.id,
                          :diaspora_handle => self.person.diaspora_handle,
                          :text => text,
                          :post => options[:on])

    #sign comment as commenter
    comment.creator_signature = comment.sign_with_key(self.encryption_key)

    if !comment.post_id.blank? && owns?(comment.post)
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
    aspect_ids = aspects_with_post(post.id)
    aspect_ids.map! { |aspect| aspect.id.to_s }

    retraction = Retraction.for(post)
    post.unsocket_from_uid(self, retraction, :aspect_ids => aspect_ids) if post.respond_to? :unsocket_from_uid
    mailman = Postzord::Dispatch.new(self, retraction)
    mailman.post 

    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    if params[:photo]
      params[:photo].update_attributes(:pending => false) if params[:photo].pending
      params[:image_url] = params[:photo].url(:thumb_large)
      params[:image_url_medium] = params[:photo].url(:thumb_medium)
      params[:image_url_small] = params[:photo].url(:thumb_small)
    end
    if self.person.profile.update_attributes(params)
      Postzord::Dispatch.new(self, profile).post
      true
    else
      false
    end
  end

  ###Invitations############
  def invite_user(email, aspect_id, invite_message = "")
    aspect_object = Aspect.first(:user_id => self.id, :id => aspect_id)
    if aspect_object
      Invitation.invite(:email => email,
                        :from => self,
                        :into => aspect_object,
                        :message => invite_message)
    else
      false
    end
  end

  def accept_invitation!(opts = {})
    if self.invited?
      log_string = "event=invitation_accepted username=#{opts[:username]} "
      log_string << "inviter=#{invitations_to_me.first.from.diaspora_handle}" if invitations_to_me.first
      Rails.logger.info log_string
      self.setup(opts)
      self.invitation_token = nil
      self.password              = opts[:password]
      self.password_confirmation = opts[:password_confirmation]
      self.save!
      invitations_to_me.each{|invitation| invitation.to_request!}

      self.reload # Because to_request adds a request and saves elsewhere
      self
    end
  end

  ###Helpers############
  def self.build(opts = {})
    u = User.new(opts)
    u.email = opts[:email]
    u.setup(opts)
    u
  end

  def setup(opts)
    self.username = opts[:username]
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0

    opts[:person] ||= {}
    opts[:person][:profile] ||= Profile.new

    self.person = Person.new(opts[:person])
    self.person.diaspora_handle = "#{opts[:username]}@#{AppConfig[:pod_uri].host}"
    self.person.url = AppConfig[:pod_url]


    self.serialized_private_key ||= User.generate_key
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
    contacts.each { |contact|
      if contact.person.owner?
        contact.person.owner.disconnected_by self.person
      else
        self.disconnect contact
      end
    }
  end
end
