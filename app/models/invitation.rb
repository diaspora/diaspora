#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  validates_presence_of :sender, :recipient, :aspect

  def self.invite(opts = {})
    return false if opts[:identifier] == opts[:from].email

    existing_user = self.find_existing_user(opts[:service], opts[:identifier])

    if existing_user
      if opts[:from].contact_for(opts[:from].person)
        raise "You are already connceted to this person"
      elsif not existing_user.invited?
        opts[:from].send_contact_request_to(existing_user.person, opts[:into])
        return
      elsif Invitation.where(:sender_id => opts[:from].id, :recipient_id => existing_user.id).first
        raise "You already invited this person"
      end
    end

    opts[:existing_user] = existing_user
    create_invitee(opts)
  end

  def self.find_existing_user(service, identifier)
    existing_user = User.where(:invitation_service => service,
                               :invitation_identifier => identifier).first
    if service == 'email'
      existing_user ||= User.where(:email => identifier).first
    else
      existing_user ||= User.joins(:services).where(:services => {:type => "Services::#{service.titleize}", :uid => identifier}).first
    end

    existing_user
  end

  def self.new_user_by_service_and_identifier(service, identifier)
    result = User.new()
    result.invitation_service = service
    result.invitation_identifier = identifier
    result.email = identifier if service == 'email'
    result.valid?
    result
  end

  def self.create_invitee(opts = {})
    invitee = opts[:existing_user] || new_user_by_service_and_identifier(opts[:service], opts[:identifier])
    return invitee if opts[:service] == 'email' && !opts[:identifier].match(Devise.email_regexp)
    invitee.invites = opts[:invites] || 5
    if invitee.new_record?
      invitee.errors.clear
      invitee.serialized_private_key = User.generate_key if invitee.serialized_private_key.blank?
      invitee.send(:generate_invitation_token)
    elsif invitee.invitation_token.nil?
      return invitee
    end

    if opts[:from]
      invitee.save(:validate => false)
      Invitation.create!(:sender => opts[:from],
                         :recipient => invitee,
                         :aspect => opts[:into],
                         :message => opts[:message])

      opts[:from].invites -= 1 unless opts[:from].invites == 0
      opts[:from].save!
      invitee.reload
    end
    invitee.invite!(:email => (opts[:service] == 'email'))
    log_string = "event=invitation_sent to=#{opts[:identifier]} service=#{opts[:service]} "
    log_string << "inviter=#{opts[:from].diaspora_handle} inviter_uid=#{opts[:from].id} inviter_created_at_unix=#{opts[:from].created_at.to_i}" if opts[:from]
    Rails.logger.info(log_string)
    invitee
  end

  def resend
    recipient.invite!
  end

  def to_request!
    request = sender.send_contact_request_to(recipient.person, aspect)
    destroy if request
    request
  end
end
