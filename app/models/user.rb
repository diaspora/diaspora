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
         :timeoutable, :token_authenticatable, :lockable,
         :lock_strategy => :none, :unlock_strategy => :none

  before_validation :strip_and_downcase_username
  before_validation :set_current_language, :on => :create

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :maximum => 32
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES
  validates_format_of :unconfirmed_email, :with  => Devise.email_regexp, :allow_blank => true

  validates_presence_of :person, :unless => proc {|user| user.invitation_token.present?}
  validates_associated :person

  has_one :person, :foreign_key => :owner_id
  delegate :public_key, :posts, :owns?, :diaspora_handle, :name, :public_url, :profile, :first_name, :last_name, :to => :person

  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id, :dependent => :destroy
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id, :dependent => :destroy
  has_many :aspects, :order => 'order_id ASC'
  has_many :aspect_memberships, :through => :aspects
  has_many :contacts
  has_many :contact_people, :through => :contacts, :source => :person
  has_many :services, :dependent => :destroy
  has_many :user_preferences, :dependent => :destroy
  has_many :tag_followings, :dependent => :destroy
  has_many :followed_tags, :through => :tag_followings, :source => :tag

  has_many :authorizations, :class_name => 'OAuth2::Provider::Models::ActiveRecord::Authorization', :foreign_key => :resource_owner_id
  has_many :applications, :through => :authorizations, :source => :client

  before_save do
    person.save if person && person.changed?
  end
  before_save :guard_unconfirmed_email

  attr_accessible :getting_started, :password, :password_confirmation, :language, :disable_mail

  def update_user_preferences(pref_hash)
    if self.disable_mail
      UserPreference::VALID_EMAIL_TYPES.each{|x| self.user_preferences.find_or_create_by_email_type(x)}
      self.disable_mail = false
      self.save
    end

    pref_hash.keys.each do |key|
      if pref_hash[key] == 'true'
        self.user_preferences.find_or_create_by_email_type(key)
      else
        block = self.user_preferences.where(:email_type => key).first
        if block
          block.destroy
        end
      end
    end
  end

  def strip_and_downcase_username
    if username.present?
      username.strip!
      username.downcase!
    end
  end

  def set_current_language
    self.language = I18n.locale.to_s if self.language.blank?
  end

  # This override allows a user to enter either their email address or their username into the username field.
  # @return [User] The user that matches the username/email condition.
  # @return [nil] if no user matches that condition.
  def self.find_for_database_authentication(conditions={})
    conditions = conditions.dup
    conditions[:username] = conditions[:username].downcase
    if conditions[:username] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i # email regex
      conditions[:email] = conditions.delete(:username)
    end
    where(conditions).first
  end

  # @param [Person] person
  # @return [Boolean] whether this user can add person as a contact.
  def can_add?(person)
    return false if self.person == person
    return false if self.contact_for(person).present?
    true
  end

  def confirm_email(token)
    return false if token.blank? || token != confirm_email_token
    self.email = unconfirmed_email
    save
  end

  ######### Aspects ######################

  def move_contact(person, to_aspect, from_aspect)
    return true if to_aspect == from_aspect
    contact = contact_for(person)

    add_contact_to_aspect(contact, to_aspect)

    membership = contact ? AspectMembership.where(:contact_id => contact.id, :aspect_id => from_aspect.id).first : nil
    return(membership && membership.destroy)
  end

  def add_contact_to_aspect(contact, aspect)
    return true if AspectMembership.exists?(:contact_id => contact.id, :aspect_id => aspect.id)
    contact.aspect_memberships.create!(:aspect => aspect)
  end

  ######## Posting ########
  def build_post(class_name, opts = {})
    opts[:author] = self.person
    opts[:diaspora_handle] = opts[:author].diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.diaspora_initialize(opts)
  end

  def dispatch_post(post, opts = {})
    additional_people = opts.delete(:additional_subscribers)
    mailman = Postzord::Dispatch.new(self, post, :additional_subscribers => additional_people)
    mailman.post(opts)
  end

  def update_post(post, post_hash = {})
    if self.owns? post
      post.update_attributes(post_hash)
      Postzord::Dispatch.new(self, post).post
    end
  end

  def notify_if_mentioned(post)
    return unless self.contact_for(post.author) && post.respond_to?(:mentions?)

    post.notify_person(self.person) if post.mentions? self.person
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
    Salmon::SalmonSlap.create(self, post.to_diaspora_xml)
  end

  def build_relayable(model, options = {})
    r = model.new(options.merge(:author_id => self.person.id))
    r.set_guid
    r.initialize_signatures
    r
  end

  ######## Commenting  ########
  def build_comment(options = {})
    build_relayable(Comment, options)
  end

  ######## Liking  ########
  def build_like(options = {})
    build_relayable(Like, options)
  end

  # Check whether the user has liked a post.
  # @param [Post] post
  def liked?(target)
    if target.likes.loaded?
      if self.like_for(target)
        return true
      else
        return false
      end
    else
      Like.exists?(:author_id => self.person.id, :target_type => target.class.base_class.to_s, :target_id => target.id)
    end
  end

  # Get the user's like of a post, if there is one.
  # @param [Post] post
  # @return [Like]
  def like_for(target)
    if target.likes.loaded?
      return target.likes.detect{ |like| like.author_id == self.person.id }
    else
      return Like.where(:author_id => self.person.id, :target_type => target.class.base_class.to_s, :target_id => target.id).first
    end
  end

  ######### Mailer #######################
  def mail(job, *args)
    pref = job.to_s.gsub('Job::Mail', '').underscore
    if(self.disable_mail == false && !self.user_preferences.exists?(:email_type => pref))
      Resque.enqueue(job, *args)
    end
  end

  def mail_confirm_email
    return false if unconfirmed_email.blank?
    Resque.enqueue(Job::MailConfirmEmail, id)
    true
  end

  ######### Posts and Such ###############
  def retract(target, opts={})
    if target.respond_to?(:relayable?) && target.relayable?
      retraction = RelayableRetraction.build(self, target)
    elsif target.is_a? Post
      retraction = SignedRetraction.build(self, target)
    else
      retraction = Retraction.for(target)
    end

   if target.is_a?(Post)
     opts[:additional_subscribers] = target.resharers
   end

    mailman = Postzord::Dispatch.new(self, retraction, opts)
    mailman.post

    retraction.perform(self)

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

  # This method is called when an invited user accepts his invitation
  #
  # @param [Hash] opts the options to accept the invitation with
  # @option opts [String] :username The username the invited user wants.
  # @option opts [String] :password
  # @option opts [String] :password_confirmation
  def accept_invitation!(opts = {})
    log_hash = {:event => :invitation_accepted, :username => opts[:username], :uid => self.id}
    log_hash[:inviter] = invitations_to_me.first.sender.diaspora_handle if invitations_to_me.first
    begin
      if self.invited?
        self.setup(opts)
        self.invitation_token = nil
        self.password              = opts[:password]
        self.password_confirmation = opts[:password_confirmation]
        self.save!
        invitations_to_me.each{|invitation| invitation.share_with!}
        log_hash[:status] = "success"
        Rails.logger.info log_hash

        self.reload # Because to_request adds a request and saves elsewhere
        self
      end
    rescue Exception => e
      log_hash[:status] =  "failure"
      Rails.logger.info log_hash
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
    self.person.diaspora_handle = "#{opts[:username]}@#{AppConfig[:pod_uri].authority}"
    self.person.url = AppConfig[:pod_url]


    self.serialized_private_key = User.generate_key if self.serialized_private_key.blank?
    self.person.serialized_public_key = OpenSSL::PKey::RSA.new(self.serialized_private_key).public_key

    self
  end

  def seed_aspects
    self.aspects.create(:name => I18n.t('aspects.seed.family'))
    self.aspects.create(:name => I18n.t('aspects.seed.friends'))
    self.aspects.create(:name => I18n.t('aspects.seed.work'))
    aq = self.aspects.create(:name => I18n.t('aspects.seed.acquaintances'))

    default_account = Webfinger.new('diasporahq@joindiaspora.com').fetch
    self.share_with(default_account, aq) if default_account
    aq
  end

  def self.generate_key
    key_size = (Rails.env == 'test' ? 512 : 4096)
    OpenSSL::PKey::RSA::generate(key_size)
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(serialized_private_key)
  end

  def admin?
    AppConfig[:admins].present? && AppConfig[:admins].include?(self.username)
  end

  def remove_all_traces
    disconnect_everyone
    remove_mentions
    remove_person
  end

  def remove_person
    self.person.destroy
  end

  def disconnect_everyone
    self.contacts.each do |contact|
      if contact.person.remote?
        self.disconnect(contact)
      else
        contact.person.owner.disconnected_by(self.person)
        remove_contact(contact, :force => true)
      end
    end
    self.aspects.destroy_all
  end

  def remove_mentions
    Mention.where( :person_id => self.person.id).delete_all
  end

  def guard_unconfirmed_email
    self.unconfirmed_email = nil if unconfirmed_email.blank? || unconfirmed_email == email

    if unconfirmed_email_changed?
      self.confirm_email_token = unconfirmed_email ? ActiveSupport::SecureRandom.hex(15) : nil
    end
  end

  def reorder_aspects(aspect_order)
    i = 0
    aspect_order.each do |id|
      self.aspects.find(id).update_attributes({ :order_id => i })
      i += 1
    end
  end
end
