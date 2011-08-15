#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  validates_presence_of :sender,
                        :recipient,
                        :aspect

  # @param opts [Hash] Takes :identifier, :service, :idenfitier, :from, :message
  # @return [User]
  def self.invite(opts={})
    opts[:identifier].downcase! if opts[:identifier]
    # return if the current user is trying to invite himself via email
    return false if opts[:identifier] == opts[:from].email

    if existing_user = self.find_existing_user(opts[:service], opts[:identifier])
      # If the sender of the invitation is already connected to the person
      # he is inviting, raise an error.
      if opts[:from].contact_for(opts[:from].person)
        raise "You are already connceted to this person"

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
  def self.find_existing_user(service, identifier)
    unless existing_user = User.where(:invitation_service => service,
                                      :invitation_identifier => identifier).first
      if service == 'email'
        existing_user ||= User.where(:email => identifier).first
      else
        existing_user ||= User.joins(:services).where(:services => {:type => "Services::#{service.titleize}", :uid => identifier}).first
      end
    end

    existing_user
  end

  # @params opts [Hash] Takes :from, :existing_user, :service, :identifier, :message
  # @return [User]
  def self.create_invitee(opts={})
    invitee = opts[:existing_user]
    invitee ||= User.new(:invitation_service => opts[:service], :invitation_identifier => opts[:identifier])

    # (dan) I'm not sure why, but we need to call .valid? on our User.
    invitee.valid?

    # Return a User immediately if an invalid email is passed in
    return invitee if opts[:service] == 'email' && !opts[:identifier].match(Devise.email_regexp)

    if invitee.new_record?
      invitee.errors.clear
      invitee.serialized_private_key = User.generate_key if invitee.serialized_private_key.blank?
      invitee.send(:generate_invitation_token)
    elsif invitee.invitation_token.nil?
      return invitee
    end

    # Logic if there is an explicit sender
    if opts[:from]
      invitee.save(:validate => false)
      Invitation.create!(:sender => opts[:from],
                         :recipient => invitee,
                         :aspect => opts[:into],
                         :message => opts[:message])
      invitee.reload
    end
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
