#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  attr_accessible :sender, :recipient, :aspect, :language, :service, :identifier, :admin, :message

  before_validation :set_email_as_default_service

 # before_create :share_with_exsisting_user, :if => :recipient_id?
  validates :identifier, :presence => true
  validates :service, :presence => true
  validate :valid_identifier?
  validate :recipient_not_on_pod?
  validates_presence_of :sender, :aspect, :unless => :admin?
  validate :ensure_not_inviting_self, :on => :create, :unless => :admin?
  validate :sender_owns_aspect?, :unless => :admin?
  validates_uniqueness_of :sender_id, :scope => [:identifier, :service], :unless => :admin?

  after_create :queue_send! #TODO make this after_commit :queue_saved!, :on => :create


  # @note options hash is passed through to [Invitation.new]
  # @see [Invitation.new]
  #
  # @param [Array<String>] emails
  # @option opts [User] :sender
  # @option opts [Aspect] :aspect
  # @option opts [String] :service
  # @return [Array<Invitation>] An array of [Invitation] models
  #   the valid ones are saved, and the invalid ones are not.
  def self.batch_invite(emails, opts)

    users_on_pod = User.where(:email => emails, :invitation_token => nil)

    #share with anyone whose email you entered who is on the pod
    users_on_pod.each{|u| opts[:sender].share_with(u.person, opts[:aspect])}

    emails.map! do |e|
      user = users_on_pod.find{|u| u.email == e}
      Invitation.create(opts.merge(:identifier => e, :recipient => user))
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
    !email_like_identifer
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


  # converts a personal invitation to an admin invite
  # used in account deletion
  # @return [Invitation] self
  def convert_to_admin!
    self.admin = true
    self.sender = nil
    self.aspect = nil
    self.save
    self
  end
  # @return [Invitation] self
  def resend
    self.send!
  end

  # @return [String]
  def recipient_identifier
    case self.service
    when 'email'
      self.identifier
    when'facebook'
      if su = ServiceUser.where(:uid => self.identifier).first
        su.name
      else
        I18n.t('invitations.a_facebook_user')
      end
    end
  end
  
  # @return [String]
  def email_like_identifer
    case self.service
    when 'email'
      self.identifier
    when 'facebook'
      if username = ServiceUser.username_of_service_user_by_uid(self.identifier) 
        unless username.include?('profile.php?')
          "#{username}@facebook.com"
        else
          nil
        end
      end
    end
  end

  def queue_send!
    unless self.recipient.present?
      Resque.enqueue(Jobs::Mail::InviteUserByEmail, self.id) 
    end
  end

  # @note before_save
  def set_email_as_default_service
    self.service ||= 'email'
  end

  # @note Validation
  def ensure_not_inviting_self
    if self.identifier == self.sender.email
      errors[:base] << 'You can not invite yourself.'
    end
  end  

  # @note Validation
  def sender_owns_aspect?
    if self.sender_id != self.aspect.user_id
      errors[:base] << 'You do not own that aspect.'
    end
  end


  def recipient_not_on_pod?
    return true if self.recipient.nil?
    if self.recipient.username?
      errors[:recipient] << "The user '#{self.identifier}' (#{self.recipient.diaspora_handle}) is already on this pod, so we sent them a share request"
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
