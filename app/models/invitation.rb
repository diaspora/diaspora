#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  validates_presence_of :identifier, :service

  validates_presence_of :sender, :aspect, :unless => :admin?
  attr_accessible :sender, :recipient, :aspect, :service, :identifier, :admin

  before_validation :set_email_as_default_service
  validate :ensure_not_inviting_self, :on => :create

  validate :valid_identifier?
  validate :sender_owns_aspect?
  validates_uniqueness_of :sender_id, :scope => [:identifier, :service], :unless => :admin?

  after_create :queue_send! #TODO make this after_commit :queue_saved!, :on => :create


  # @note options hash is passed through to [Invitation.new]
  # @see [Invitation.new]
  #
  # @option opts [Array<String>] :emails
  # @return [Array<Invitation>] An array of initialized [Invitation] models.
  def self.batch_build(opts)
    emails = opts.delete(:emails)
    emails.map! do |e|
      Invitation.create(opts.merge(:identifier => e))
    end
    emails
  end

  # Downcases the incoming service identifier and assigns it
  #
  # @param ident [String] Service identifier
  # @see super
  def identifier=(ident)
    ident.downcase! if ident
    super
  end

  # Determine if we want to skip emailing the recipient.
  #
  # @return [Boolean]
  # @return [void]
  def skip_email?
    self.service != 'email'
  end

  # Attach a recipient [User] to the [Invitation] unless
  # there is one already present.
  #
  # @return [User] The recipient.
  def attach_recipient!
    unless self.recipient.present?
      self.recipient = User.find_or_create_by_invitation(self) 
      self.save
    end
    self.recipient
  end

  # Find or create user, and send that resultant User an
  # invitation.
  #
  # @return [Invitation] self
  def send!
    self.attach_recipient!
    
    # Sets an instance variable in User (set by devise invitable)
    # This determines whether an email should be sent to the recipient.
    recipient.skip_invitation = self.skip_email?

    recipient.invite!

    # Logging the invitation action
    log_hash = {:event => :invitation_sent, :to => self[:identifier], :service => self[:service]}
    log_hash.merge({:inviter => self.sender.diaspora_handle, :invitier_uid => self.sender.id, :inviter_created_at_unix => self.sender.created_at.to_i}) if self.sender
    Rails.logger.info(log_hash)

    self
  end

  # @return [Invitation] self
  def resend
    self.send!
  end

  # @return [String]
  def recipient_identifier
    if self.service == 'email'
      self.identifier
    elsif self.service == 'facebook'
      if su = ServiceUser.where(:uid => self.identifier).first
        su.name
      else
        I18n.t('invitations.a_facebook_user')
      end
    end
  end

  def queue_send!
    unless self.recipient.present?
      Resque.enqueue(Job::Mail::InviteUserByEmail, self.id) 
    end
  end

  # @note before_save
  def set_email_as_default_service
    self.service ||= 'email'
  end

  # @note Validation
  def ensure_not_inviting_self
    if !self.admin? && self.identifier == self.sender.email
      errors[:base] << 'You can not invite yourself'
    end
  end  

  # @note Validation
  def sender_owns_aspect?
    unless(self.sender && (self.sender_id == self.aspect.user_id))
      errors[:base] << 'You do not own that aspect'
    end
  end


  # @note Validation
  def valid_identifier?
    return false unless self.identifier
    if self.service == 'email'
      unless self.identifier.match(Devise.email_regexp)
        errors[:base] << 'invalid email'
      end
    end
  end
end
