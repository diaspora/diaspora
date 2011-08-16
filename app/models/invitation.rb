#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  validates_presence_of :sender,
                        :recipient,
                        :aspect,
                        :identifier,
                        :service

  attr_accessible :sender, :recipient, :aspect, :service, :identifier

  before_validation :set_email_as_default_service
  before_validation :attach_recipient, :on => :create
  before_create :ensure_not_inviting_self

  validate :valid_identifier?
  validates_uniqueness_of :sender, :scope => :recipient

  def set_email_as_default_service
    self.service ||='email'
  end

  def identifier=(ident)
    ident.downcase! if ident
    super
  end

  def not_inviting_yourself
    if self.identifier == self.sender.email
      errors[:base] << 'You can not invite yourself'
    end
  end  
  
  def attach_recipient
    self.recipient = User.find_or_create_by_invitation(self)
  end

  def skip_invitation?
    self.service != 'email'
  end

  # @return Contact
  def share_with!
    if contact = sender.share_with(recipient.person, aspect)
      self.destroy
    end
    contact
  end

  def invite!
    recipient.skip_invitation = self.skip_invitation?
    recipient.invite!

    # Logging the invitation action
    log_hash = {:event => :invitation_sent, :to => self[:identifier], :service => self[:service]}
    log_hash.merge({:inviter => self.sender.diaspora_handle, :invitier_uid => self.sender.id, :inviter_created_at_unix => self.sender.created_at.to_i}) if self.sender
    Rails.logger.info(log_hash)

    recipient
  end

  def resend
    self.invite!
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

  def valid_identifier?
    if self.service == 'email'
      unless self.identifier.match(Devise.email_regexp)
        errors[:base] << 'invalid email'
      end
    end
  end
end
