#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class User < ActiveRecord::Base
  include Encryptor::Private
  include Connecting
  include Querying
  include SocialActions

  apply_simple_captcha :message => I18n.t('simple_captcha.message.failed'), :add_to_base => true

  scope :logged_in_since, lambda { |time| where('last_seen > ?', time) }
  scope :monthly_actives, lambda { |time = Time.now| logged_in_since(time - 1.month) }
  scope :daily_actives, lambda { |time = Time.now| logged_in_since(time - 1.day) }
  scope :yearly_actives, lambda { |time = Time.now| logged_in_since(time - 1.year) }
  scope :halfyear_actives, lambda { |time = Time.now| logged_in_since(time - 6.month) }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :lastseenable, :lock_strategy => :none, :unlock_strategy => :none

  before_validation :strip_and_downcase_username
  before_validation :set_current_language, :on => :create

  validates :username, :presence => true, :uniqueness => true
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :maximum => 32
  validates_exclusion_of :username, :in => AppConfig.settings.username_blacklist
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES
  validates_format_of :unconfirmed_email, :with  => Devise.email_regexp, :allow_blank => true

  validates_presence_of :person, :unless => proc {|user| user.invitation_token.present?}
  validates_associated :person
  validate :no_person_with_same_username

  serialize :hidden_shareables, Hash

  has_one :person, :foreign_key => :owner_id
  delegate :guid, :public_key, :posts, :photos, :owns?, :image_url,
           :diaspora_handle, :name, :public_url, :profile, :url,
           :first_name, :last_name, :gender, :participations, to: :person
  delegate :id, :guid, to: :person, prefix: true

  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id
  has_many :aspects, :order => 'order_id ASC'

  belongs_to  :auto_follow_back_aspect, :class_name => 'Aspect'
  belongs_to :invited_by, :class_name => 'User'

  has_many :aspect_memberships, :through => :aspects

  has_many :contacts
  has_many :contact_people, :through => :contacts, :source => :person

  has_many :services

  has_many :user_preferences

  has_many :tag_followings
  has_many :followed_tags, :through => :tag_followings, :source => :tag, :order => 'tags.name'

  has_many :blocks
  has_many :ignored_people, :through => :blocks, :source => :person

  has_many :conversation_visibilities, through: :person, order: 'updated_at DESC'
  has_many :conversations, through: :conversation_visibilities, order: 'updated_at DESC'

  has_many :notifications, :foreign_key => :recipient_id

  has_many :reports

  before_save :guard_unconfirmed_email,
              :save_person!

  def self.all_sharing_with_person(person)
    User.joins(:contacts).where(:contacts => {:person_id => person.id})
  end

  def unread_notifications
    notifications.where(:unread => true)
  end

  def unread_message_count
    ConversationVisibility.sum(:unread, :conditions => "person_id = #{self.person.id}")
  end

  #@deprecated
  def ugly_accept_invitation_code
    begin
      self.invitations_to_me.first.sender.invitation_code
    rescue Exception => e
      nil
    end
  end

  def process_invite_acceptence(invite)
    self.invited_by = invite.user
    invite.use!
  end


  def invitation_code
    InvitationCode.find_or_create_by(user_id: self.id)
  end

  def hidden_shareables
    self[:hidden_shareables] ||= {}
  end

  def add_hidden_shareable(key, share_id, opts={})
    if self.hidden_shareables.has_key?(key)
      self.hidden_shareables[key] << share_id
    else
      self.hidden_shareables[key] = [share_id]
    end
    self.save unless opts[:batch]
    self.hidden_shareables
  end

  def remove_hidden_shareable(key, share_id)
    if self.hidden_shareables.has_key?(key)
      self.hidden_shareables[key].delete(share_id)
    end
  end

  def is_shareable_hidden?(shareable)
    shareable_type = shareable.class.base_class.name
    if self.hidden_shareables.has_key?(shareable_type)
      self.hidden_shareables[shareable_type].include?(shareable.id.to_s)
    else
      false
    end
  end

  def toggle_hidden_shareable(share)
    share_id = share.id.to_s
    key = share.class.base_class.to_s
    if self.hidden_shareables.has_key?(key) && self.hidden_shareables[key].include?(share_id)
      self.remove_hidden_shareable(key, share_id)
      self.save
      false
    else
      self.add_hidden_shareable(key, share_id)
      self.save
      true
    end
  end

  def has_hidden_shareables_of_type?(t = Post)
    share_type = t.base_class.to_s
    self.hidden_shareables[share_type].present?
  end

  # Copy the method provided by Devise to be able to call it later
  # from a Sidekiq job
  alias_method :send_reset_password_instructions!, :send_reset_password_instructions

  def send_reset_password_instructions
    Workers::ResetPassword.perform_async(self.id)
  end

  def update_user_preferences(pref_hash)
    if self.disable_mail
      UserPreference::VALID_EMAIL_TYPES.each{|x| self.user_preferences.find_or_create_by(email_type: x)}
      self.disable_mail = false
      self.save
    end

    pref_hash.keys.each do |key|
      if pref_hash[key] == 'true'
        self.user_preferences.find_or_create_by(email_type: key)
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

  def disable_getting_started
    self.update_attribute(:getting_started, false) if self.getting_started?
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

  def confirm_email(token)
    return false if token.blank? || token != confirm_email_token
    self.email = unconfirmed_email
    save
  end

  ######### Aspects ######################
  def add_contact_to_aspect(contact, aspect)
    return true if AspectMembership.exists?(:contact_id => contact.id, :aspect_id => aspect.id)
    contact.aspect_memberships.create!(:aspect => aspect)
  end

  ######## Posting ########
  def build_post(class_name, opts={})
    opts[:author] = self.person
    opts[:diaspora_handle] = opts[:author].diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.diaspora_initialize(opts)
  end

  def dispatch_post(post, opts={})
    FEDERATION_LOGGER.info("user:#{self.id} dispatching #{post.class}:#{post.guid}")
    Postzord::Dispatcher.defer_build_and_post(self, post, opts)
  end

  def update_post(post, post_hash={})
    if self.owns? post
      post.update_attributes(post_hash)
      self.dispatch_post(post)
    end
  end

  def notify_if_mentioned(post)
    return unless self.contact_for(post.author) && post.respond_to?(:mentions?)

    post.notify_person(self.person) if post.mentions? self.person
  end

  def add_to_streams(post, aspects_to_insert)
    aspects_to_insert.each do |aspect|
      aspect << post
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
    Salmon::EncryptedSlap.create_by_user_and_activity(self, post.to_diaspora_xml)
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
    pref = job.to_s.gsub('Workers::Mail::', '').underscore
    if(self.disable_mail == false && !self.user_preferences.exists?(:email_type => pref))
      job.perform_async(*args)
    end
  end

  def mail_confirm_email
    return false if unconfirmed_email.blank?
    Workers::Mail::ConfirmEmail.perform_async(id)
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
     opts[:services] = self.services
   end

    mailman = Postzord::Dispatcher.build(self, retraction, opts)
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

    params.stringify_keys!
    params.slice!(*(Profile.column_names+['tag_string', 'date']))
    if self.profile.update_attributes(params)
      deliver_profile_update
      true
    else
      false
    end
  end

  def update_profile_with_omniauth( user_info )
    update_profile( self.profile.from_omniauth_hash( user_info ) )
  end

  def deliver_profile_update
    Postzord::Dispatcher.build(self, profile).post
  end

  ###Helpers############
  def self.build(opts = {})
    u = User.new(opts.except(:person))
    u.setup(opts)
    u
  end

  def setup(opts)
    self.username = opts[:username]
    self.email = opts[:email]
    self.language = opts[:language]
    self.language ||= I18n.locale.to_s
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0
    self.set_person(Person.new(opts[:person] || {} ))
    self.generate_keys
    self
  end

  def set_person(person)
    person.url = AppConfig.pod_uri.to_s
    person.diaspora_handle = "#{self.username}#{User.diaspora_id_host}"
    self.person = person
  end

  def self.diaspora_id_host
    "@#{AppConfig.bare_pod_uri}"
  end

  def seed_aspects
    self.aspects.create(:name => I18n.t('aspects.seed.family'))
    self.aspects.create(:name => I18n.t('aspects.seed.friends'))
    self.aspects.create(:name => I18n.t('aspects.seed.work'))
    aq = self.aspects.create(:name => I18n.t('aspects.seed.acquaintances'))

    if AppConfig.settings.autofollow_on_join?
      default_account = Webfinger.new(AppConfig.settings.autofollow_on_join_user).fetch
      self.share_with(default_account, aq) if default_account
    end
    aq
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(serialized_private_key)
  end

  def admin?
    Role.is_admin?(self.person)
  end

  def mine?(target)
    if target.present? && target.respond_to?(:user_id)
      return self.id == target.user_id
    end

    false
  end


  def guard_unconfirmed_email
    self.unconfirmed_email = nil if unconfirmed_email.blank? || unconfirmed_email == email

    if unconfirmed_email_changed?
      self.confirm_email_token = unconfirmed_email ? SecureRandom.hex(15) : nil
    end
  end

  # Generate public/private keys for User and associated Person
  def generate_keys
    key_size = (Rails.env == 'test' ? 512 : 4096)

    self.serialized_private_key = OpenSSL::PKey::RSA::generate(key_size).to_s if self.serialized_private_key.blank?

    if self.person && self.person.serialized_public_key.blank?
      self.person.serialized_public_key = OpenSSL::PKey::RSA.new(self.serialized_private_key).public_key.to_s
    end
  end

  # Sometimes we access the person in a strange way and need to do this
  # @note we should make this method depricated.
  #
  # @return [Person]
  def save_person!
    self.person.save if self.person && self.person.changed?
    self.person
  end


  def no_person_with_same_username
    diaspora_id = "#{self.username}#{User.diaspora_id_host}"
    if self.username_changed? && Person.exists?(:diaspora_handle => diaspora_id)
      errors[:base] << 'That username has already been taken'
    end
  end

  def close_account!
    self.person.lock_access!
    self.lock_access!
    AccountDeletion.create(:person => self.person)
  end

  def clear_account!
    clearable_fields.each do |field|
      self[field] = nil
    end
    [:getting_started,
     :disable_mail,
     :show_community_spotlight_in_stream].each do |field|
      self[field] = false
    end
    self[:email] = "deletedaccount_#{self[:id]}@example.org"

    random_password = SecureRandom.hex(20)
    self.password = random_password
    self.password_confirmation = random_password
    self.save(:validate => false)
  end

  def sign_up
    if AppConfig.settings.captcha.enable?
      save_with_captcha
    else
      save
    end
  end
  
  private
  def clearable_fields
    self.attributes.keys - ["id", "username", "encrypted_password",
                            "created_at", "updated_at", "locked_at",
                            "serialized_private_key", "getting_started",
                            "disable_mail", "show_community_spotlight_in_stream",
                            "email"]
  end
end
