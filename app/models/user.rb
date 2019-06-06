# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class User < ApplicationRecord
  include AuthenticationToken
  include Connecting
  include Querying
  include SocialActions

  apply_simple_captcha :message => I18n.t('simple_captcha.message.failed'), :add_to_base => true

  scope :logged_in_since, ->(time) { where('last_seen > ?', time) }
  scope :monthly_actives, ->(time = Time.now) { logged_in_since(time - 1.month) }
  scope :daily_actives, ->(time = Time.now) { logged_in_since(time - 1.day) }
  scope :yearly_actives, ->(time = Time.now) { logged_in_since(time - 1.year) }
  scope :halfyear_actives, ->(time = Time.now) { logged_in_since(time - 6.month) }
  scope :active, -> { joins(:person).where(people: {closed_account: false}) }

  attr_encrypted :otp_secret, if: false, prefix: "plain_"

  devise :two_factor_authenticatable,
         :two_factor_backupable,
         otp_backup_code_length:     16,
         otp_number_of_backup_codes: 10

  devise :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :lastseenable, :lock_strategy => :none, :unlock_strategy => :none

  before_validation :strip_and_downcase_username
  before_validation :set_current_language, :on => :create
  before_validation :set_default_color_theme, on: :create

  validates :username, :presence => true, :uniqueness => true
  validates_format_of :username, :with => /\A[A-Za-z0-9_]+\z/
  validates_length_of :username, :maximum => 32
  validates_exclusion_of :username, :in => AppConfig.settings.username_blacklist
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES
  validates :color_theme, inclusion: {in: AVAILABLE_COLOR_THEMES}, allow_blank: true
  validates_format_of :unconfirmed_email, :with  => Devise.email_regexp, :allow_blank => true

  validate :unconfirmed_email_quasiuniqueness

  validates :person, presence: true
  validates_associated :person
  validate :no_person_with_same_username

  serialize :hidden_shareables, Hash
  serialize :otp_backup_codes, Array

  has_one :person, inverse_of: :owner, foreign_key: :owner_id
  has_one :profile, through: :person

  delegate :guid, :public_key, :posts, :photos, :owns?, :image_url,
           :diaspora_handle, :name, :atom_url, :profile_url, :profile, :url,
           :first_name, :last_name, :full_name, :gender, :participations, to: :person
  delegate :id, :guid, to: :person, prefix: true

  has_many :aspects, -> { order('order_id ASC') }

  belongs_to :auto_follow_back_aspect, class_name: "Aspect", optional: true
  belongs_to :invited_by, class_name: "User", optional: true

  has_many :invited_users, class_name: "User", inverse_of: :invited_by, foreign_key: :invited_by_id

  has_many :aspect_memberships, :through => :aspects

  has_many :contacts
  has_many :contact_people, :through => :contacts, :source => :person

  has_many :services

  has_many :user_preferences

  has_many :tag_followings
  has_many :followed_tags, -> { order('tags.name') }, :through => :tag_followings, :source => :tag

  has_many :blocks
  has_many :ignored_people, :through => :blocks, :source => :person

  has_many :conversation_visibilities, through: :person
  has_many :conversations, through: :conversation_visibilities

  has_many :notifications, :foreign_key => :recipient_id

  has_many :reports

  has_many :pairwise_pseudonymous_identifiers, class_name: "Api::OpenidConnect::PairwisePseudonymousIdentifier"
  has_many :authorizations, class_name: "Api::OpenidConnect::Authorization"
  has_many :o_auth_applications, through: :authorizations, class_name: "Api::OpenidConnect::OAuthApplication"

  has_many :share_visibilities

  before_save :guard_unconfirmed_email

  after_save :remove_invalid_unconfirmed_emails

  before_destroy do
    raise "Never destroy users!"
  end

  def self.all_sharing_with_person(person)
    User.joins(:contacts).where(:contacts => {:person_id => person.id})
  end

  def unread_notifications
    notifications.where(:unread => true)
  end

  def unread_message_count
    ConversationVisibility.where(person_id: self.person_id).sum(:unread)
  end

  def process_invite_acceptence(invite)
    self.invited_by = invite.user
    invite.use! unless AppConfig.settings.enable_registrations?
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
        block = user_preferences.find_by(email_type: key)
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

  def set_default_color_theme
    self.color_theme ||= AppConfig.settings.default_color_theme
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

  ######## Posting ########
  def build_post(class_name, opts={})
    opts[:author] = person

    model_class = class_name.to_s.camelize.constantize
    model_class.diaspora_initialize(opts)
  end

  def dispatch_post(post, opts={})
    logger.info "user:#{id} dispatching #{post.class}:#{post.guid}"
    Diaspora::Federation::Dispatcher.defer_dispatch(self, post, opts)
  end

  def update_post(post, post_hash={})
    if self.owns? post
      post.update_attributes(post_hash)
      self.dispatch_post(post)
    end
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
      aspects.where(:id => aspect_ids).to_a
    end
  end

  def post_default_aspects
    if post_default_public
      ["public"]
    else
      aspects.where(post_default: true).to_a
    end
  end

  def update_post_default_aspects(post_default_aspect_ids)
    aspects.each do |aspect|
      enable = post_default_aspect_ids.include?(aspect.id.to_s)
      aspect.update_attribute(:post_default, enable)
    end
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
      target.likes.find {|like| like.author_id == person.id }
    else
      Like.find_by(author_id: person.id, target_type: target.class.base_class.to_s, target_id: target.id)
    end
  end

  ######### Data export ##################
  mount_uploader :export, ExportedUser

  def queue_export
    update exporting: true, export: nil, exported_at: nil
    Workers::ExportUser.perform_async(id)
  end

  def perform_export!
    export = Tempfile.new([username, ".json.gz"], encoding: "ascii-8bit")
    export.write(compressed_export) && export.close
    if export.present?
      update exporting: false, export: export, exported_at: Time.zone.now
    else
      update exporting: false
    end
  rescue => error
    logger.error "Unexpected error while exporting user '#{username}': #{error.class}: #{error.message}\n" \
                 "#{error.backtrace.first(15).join("\n")}"
    update exporting: false
  end

  def compressed_export
    ActiveSupport::Gzip.compress Diaspora::Exporter.new(self).execute
  end

  ######### Photos export ##################
  mount_uploader :exported_photos_file, ExportedPhotos

  def queue_export_photos
    update exporting_photos: true, exported_photos_file: nil, exported_photos_at: nil
    Workers::ExportPhotos.perform_async(id)
  end

  def perform_export_photos!
    PhotoExporter.new(self).perform
  rescue => error
    logger.error "Unexpected error while exporting photos for '#{username}': #{error.class}: #{error.message}\n" \
                 "#{error.backtrace.first(15).join("\n")}"
    update exporting_photos: false
  end

  ######### Mailer #######################
  def mail(job, *args)
    return unless job.present?
    pref = job.to_s.gsub('Workers::Mail::', '').underscore
    if(self.disable_mail == false && !self.user_preferences.exists?(:email_type => pref))
      job.perform_async(*args)
    end
  end

  def send_confirm_email
    return if unconfirmed_email.blank?
    Workers::Mail::ConfirmEmail.perform_async(id)
  end

  ######### Posts and Such ###############
  def retract(target)
    retraction = Retraction.for(target)
    retraction.defer_dispatch(self)
    retraction.perform
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

  def deliver_profile_update(opts={})
    Diaspora::Federation::Dispatcher.defer_dispatch(self, profile, opts)
  end

  def basic_profile_present?
    tag_followings.any? || profile[:image_url]
  end

  ###Helpers############
  def self.build(opts = {})
    u = User.new(opts.except(:person, :id))
    u.setup(opts)
    u
  end

  def setup(opts)
    self.username = opts[:username]
    self.email = opts[:email]
    self.language = opts[:language]
    self.language ||= I18n.locale.to_s
    self.color_theme = opts[:color_theme]
    self.color_theme ||= AppConfig.settings.default_color_theme
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0
    self.set_person(Person.new((opts[:person] || {}).except(:id)))
    self.generate_keys
    self
  end

  def set_person(person)
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
      default_account = Person.find_or_fetch_by_identifier(AppConfig.settings.autofollow_on_join_user)
      self.share_with(default_account, aq) if default_account
    end
    aq
  end

  def send_welcome_message
    return unless AppConfig.settings.welcome_message.enabled? && AppConfig.admins.account?
    sender_username = AppConfig.admins.account.get
    sender = User.find_by(username: sender_username)
    return if sender.nil?
    conversation = sender.build_conversation(
      participant_ids: [sender.person.id, person.id],
      subject:         AppConfig.settings.welcome_message.subject.get,
      message:         {text: AppConfig.settings.welcome_message.text.get % {username: username}}
    )

    Diaspora::Federation::Dispatcher.build(sender, conversation).dispatch if conversation.save
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(serialized_private_key)
  end

  def admin?
    Role.is_admin?(self.person)
  end

  def moderator?
    Role.moderator?(person)
  end

  def moderator_only?
    Role.moderator_only?(person)
  end

  def spotlight?
    Role.spotlight?(person)
  end

  def podmin_account?
    username == AppConfig.admins.account
  end

  def mine?(target)
    if target.present? && target.respond_to?(:user_id)
      return self.id == target.user_id
    end

    false
  end


  # Ensure that the unconfirmed email isn't already someone's email
  def unconfirmed_email_quasiuniqueness
    if User.exists?(["id != ? AND email = ?", id, unconfirmed_email])
      errors.add(:unconfirmed_email, I18n.t("errors.messages.taken"))
    end
  end

  def guard_unconfirmed_email
    self.unconfirmed_email = nil if unconfirmed_email.blank? || unconfirmed_email == email

    return unless will_save_change_to_unconfirmed_email?

    self.confirm_email_token = unconfirmed_email ? SecureRandom.hex(15) : nil
  end

  # Whenever email is set, clear all unconfirmed emails which match
  def remove_invalid_unconfirmed_emails
    return unless saved_change_to_email?
    # rubocop:disable Rails/SkipsModelValidations
    User.where(unconfirmed_email: email).update_all(unconfirmed_email: nil, confirm_email_token: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end

  # Generate public/private keys for User and associated Person
  def generate_keys
    key_size = (Rails.env == "test" ? 512 : 4096)

    self.serialized_private_key = OpenSSL::PKey::RSA.generate(key_size).to_s if serialized_private_key.blank?

    if self.person && self.person.serialized_public_key.blank?
      self.person.serialized_public_key = OpenSSL::PKey::RSA.new(self.serialized_private_key).public_key.to_s
    end
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
    AccountDeletion.create(person: person)
  end

  def closed_account?
    self.person.closed_account
  end

  def clear_account!
    clearable_fields.each do |field|
      self[field] = nil
    end
    [:getting_started,
     :show_community_spotlight_in_stream,
     :post_default_public].each do |field|
      self[field] = false
    end
    self.remove_export = true
    self.remove_exported_photos_file = true
    self[:disable_mail] = true
    self[:strip_exif] = true
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

  def flag_for_removal(remove_after)
    # flag inactive user for future removal
    if AppConfig.settings.maintenance.remove_old_users.enable?
      self.remove_after = remove_after
      self.save
    end
  end

  def after_database_authentication
    # remove any possible remove_after timestamp flag set by maintenance.remove_old_users
    unless self.remove_after.nil?
      self.remove_after = nil
      self.save
    end
  end

  def remember_me
    true
  end

  private

  def clearable_fields
    attributes.keys - %w(id username encrypted_password created_at updated_at locked_at
                         serialized_private_key getting_started
                         disable_mail show_community_spotlight_in_stream
                         strip_exif email remove_after export exporting
                         exported_photos_file exporting_photos)
  end
end
