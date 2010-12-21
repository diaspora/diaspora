#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/diaspora/user')
require File.join(Rails.root, 'lib/salmon/salmon')
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
  delegate :public_key, :posts, :owns?, :diaspora_handle, :name, :public_url, :profile, :to => :person

  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id
  has_many :aspects, :dependent => :destroy
  has_many :aspect_memberships, :through => :aspects
  has_many :contacts
  has_many :contact_people, :through => :contacts
  has_many :services

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

  def add_contact_to_aspect(contact, aspect)
    return true if contact.aspect_memberships.where(:aspect_id => aspect.id).count > 0
    contact.aspect_memberships.create!(:aspect => aspect)
  end

  def delete_person_from_aspect(person_id, aspect_id, opts = {})
    aspect = Aspect.find(aspect_id)
    raise "Can not delete a person from an aspect you do not own" unless aspect.user == self
    contact = contact_for Person.find(person_id)

    if opts[:force] || contact.aspect_ids.count > 1
      contact.aspects.delete(aspect)
    else
      raise "Can not delete a person from last aspect"
    end
  end

  ######## Posting ########
  def build_post(class_name, opts = {})
    opts[:person] = self.person
    opts[:diaspora_handle] = opts[:person].diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.diaspora_initialize(opts)
  end

  def dispatch_post(post, opts = {})
    aspect_ids = opts.delete(:to)

    Rails.logger.info("event=dispatch user=#{diaspora_handle} post=#{post.id.to_s}")
    push_to_aspects(post, aspects_from_ids(aspect_ids))
    Resque.enqueue(Jobs::PostToServices, self.id, post.id, opts[:url]) if post.public
  end

  def post_to_services(post, url)
    if post.respond_to?(:message)
      self.services.each do |service|
        service.post(post, url)
      end
    end
  end

  def post_to_hub(post)
    Rails.logger.debug("event=post_to_service type=pubsub sender_handle=#{self.diaspora_handle}")
    EventMachine::PubSubHubbub.new(APP_CONFIG[:pubsub_server]).publish self.public_url
  end

  def update_post(post, post_hash = {})
    if self.owns? post
      post.update_attributes(post_hash)
      aspects = self.aspects.joins(:posts).where(:posts => {:id => post.id})
      self.push_to_aspects(post, aspects)
    end
  end

  def add_to_streams(post, aspect_ids)
    post.socket_to_uid(id, :aspect_ids => aspect_ids) if post.respond_to? :socket_to_uid
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
      aspect_ids = [aspect_ids] unless aspect_ids.is_a?(Array)
      aspects.where(:id => aspect_ids)
    end
  end

  def push_to_aspects(post, aspects)
    #send to the aspects
    target_aspect_ids = aspects.map {|a| a.id}

    #target_contacts = Contact.where(:user_id => self.id, "aspect_memberships
    target_people = Person.joins(
      :contacts => :aspect_memberships
    ).where(:aspect_memberships => {:aspect_id => target_aspect_ids})
    #target_people = Person.includes(:contacts).where(
    #  "contacts.user_id" => self.id,
    #  "contacts.aspect_memberships.aspect_id" => target_aspect_ids,
    #  "contacts.pending" => false)

    post_to_hub(post) if post.respond_to?(:public) && post.public
    push_to_people(post, target_people)
  end

  def push_to_people(post, people)
    salmon = salmon(post)
    people.each do |person|
      push_to_person(salmon, post, person)
    end
  end

  def push_to_person(salmon, post, person)
    person.reload # Sadly, we need this for Ruby 1.9.
    # person.owner will always return a ProxyObject.
    # calling nil? performs a necessary evaluation.
    if person.owner_id
      Rails.logger.info("event=push_to_person route=local sender=#{self.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{post.class}")

      if post.is_a?(Post) || post.is_a?(Comment)
        Resque.enqueue(Jobs::ReceiveLocal, person.owner_id, self.person.id, post.class.to_s, post.id)
      else
        Resque.enqueue(Jobs::Receive, person.owner_id, post.to_diaspora_xml, self.person.id)
      end
    else
      xml = salmon.xml_for person
      Rails.logger.info("event=push_to_person route=remote sender=#{self.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{post.class}")
      MessageHandler.add_post_request(person.receive_url, xml)
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

    #sign comment as commenter
    comment.creator_signature = comment.sign_with_key(self.encryption_key)

    if !comment.post_id.blank? && person.owns?(comment.post)
      #sign comment as post owner
      comment.post_creator_signature = comment.sign_with_key(self.encryption_key)
    end

    comment
  end

  def dispatch_comment(comment)
    if person.owns? comment.post
      #push DOWNSTREAM (to original audience)
      Rails.logger.info "event=dispatch_comment direction=downstream user=#{self.person.diaspora_handle} comment=#{comment.id}"
      aspects = comment.post.aspects

      #just socket to local users, as the comment has already
      #been associated and saved by post owner
      #  (we'll push to all of their aspects for now, the comment won't
      #   show up via js where corresponding posts are not present)

      people_in_aspects(aspects, :type => 'local').each do |person|
        comment.socket_to_uid(person.owner_id, :aspect_ids => 'all')
      end

      #push to remote people
      push_to_people(comment, people_in_aspects(aspects, :type => 'remote'))

    elsif owns? comment
      #push UPSTREAM (to poster)
      Rails.logger.info "event=dispatch_comment direction=upstream user=#{self.diaspora_handle} comment=#{comment.id}"
      push_to_people comment, [comment.post.person]
    end
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

    post.unsocket_from_uid(self.id, :aspect_ids => aspects.map { |a| a.id.to_s }) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    push_to_people retraction, people_in_aspects(aspects)
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
      push_to_people profile, contacts.includes(:person).where(:pending => false).map{|c| c.person}
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
      log_string << "inviter=#{invitations_to_me.first.sender.diaspora_handle}" if invitations_to_me.first
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
    unless opts[:person][:profile].is_a?(Profile)
      opts[:person][:profile] ||= Profile.new
      opts[:person][:profile] = Profile.new(opts[:person][:profile])
    end

    self.person = Person.new(opts[:person])
    self.person.diaspora_handle = "#{opts[:username]}@#{APP_CONFIG[:pod_uri].host}"
    self.person.url = APP_CONFIG[:pod_url]


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
