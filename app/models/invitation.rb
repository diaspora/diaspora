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
    existing_user = User.where(:email => opts[:identifier]).first

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
    create_invitee(opts)
  end

  def self.new_or_existing_user_by_service_and_identifier(service, identifier)
    existing_user = User.where(:invitation_service => service,
                               :invitation_identifier => identifier).first
    if service == 'email'
      existing_user ||= User.where(:email => identifier).first
    else
      existing_user ||= User.joins(:services).where(:services => {:provider => service, :uid => identifier}).first
    end

    if existing_user
      existing_user
    else
      result = User.new()
      result.invitation_service = service
      result.invitation_identifier = identifier
      result.email = identifier if service == 'email'
      result.valid?
      result
    end
  end

  def self.create_invitee(opts = {})
    invitee = new_or_existing_user_by_service_and_identifier(opts[:service], opts[:identifier])
    return invitee unless opts[:service] == 'email' && opts[:identifier].match(Devise.email_regexp)
    invitee.invites = opts[:invites] || 0
    if invitee.new_record?
      invitee.errors.clear
      invitee.serialized_private_key ||= User.generate_key
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
    invitee.invite!
    Rails.logger.info("event=invitation_sent to=#{opts[:identifier]} #{"inviter=#{opts[:from].diaspora_handle}" if opts[:from]}")
    invitee
  end

  def to_request!
    request = sender.send_contact_request_to(recipient.person, aspect)
    destroy if request
    request
  end
end
