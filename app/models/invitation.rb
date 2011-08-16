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

  before_validation :attach_recipent, :on => :create
  before_create :ensure_not_inviting_self

  validate :valid_identifier?
  validates_uniqueness_of :sender, :scope => :recipient


  def identifier=(ident)
    ident.downcase! if ident
    ident
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
  
  end

  def valid_identifier?
    if self.service == 'email'
      unless self.identifier.match(Devise.email_regexp)
        errors[:base] << 'You can not invite yourself'
      end
    end
  end
end

    











































  # @param opts [Hash] Takes :identifier, :service, :idenfitier, :from, :message
  # @return [User]
  def self.invite(opts={})
    # return if the current user is trying to invite himself via email
    return false if opts[:identifier] == opts[:from].email

    if existing_user = self.find_existing_user(opts[:service], opts[:identifier])
      # Check whether or not the existing User has already been invited;
      # and if so, start sharing with the Person.
      elsif not existing_user.invited?
        opts[:from].share_with(existing_user.person, opts[:into])
        return

      # If the sender has already invited the recipient, raise an error.
      elsif Invitation.where(:sender_id => opts[:from].id, :recipient_id => existing_user.id).first
        raise "You already invited this person"

      # When everything checks out, we merge the existing user into the
      # options hash to pass on to self.create_invitee.
      else
        opts.merge(:existing_user => existing_user)
      end
    end

    create_invitee(opts)
  end

  # @param service [String] String representation of the service invitation provider (i.e. facebook, email)
  # @param identifier [String] String representation of the reciepients identity on the provider (i.e. 'bob.smith', bob@aol.com)
  # @return [User]

  # @params opts [Hash] Takes :from, :existing_user, :service, :identifier, :message
  # @return [User]
  def self.create_invitee(opts={})
    invitee = opts[:existing_user]
    invitee ||= User.new(:invitation_service => opts[:service], :invitation_identifier => opts[:identifier])

    # (dan) I'm not sure why, but we need to call .valid? on our User.
    invitee.valid?

    # Return a User immediately if an invalid email is passed in

    # Logic if there is an explicit sender

    invitee.skip_invitation = (opts[:service] != 'email')
    invitee.invite!

    # Logging the invitation action
    log_hash = {:event => :invitation_sent, :to => opts[:identifier], :service => opts[:service]}
    log_hash.merge({:inviter => opts[:from].diaspora_handle, :invitier_uid => opts[:from].id, :inviter_created_at_unix => opts[:from].created_at.to_i}) if opts[:from]
    Rails.logger.info(log_hash)

    invitee
  end

  def resend
    recipient.invite!
  end

  # @return Contact
  def share_with!
    if contact = sender.share_with(recipient.person, aspect)
      self.destroy
    end
    contact
  end

  # @return [String]
  def recipient_identifier
    if recipient.invitation_service == 'email'
      recipient.invitation_identifier
    elsif recipient.invitation_service == 'facebook'
      if su = ServiceUser.where(:uid => recipient.invitation_identifier).first
        su.name
      else
        I18n.t('invitations.a_facebook_user')
      end
    end
  end
end
