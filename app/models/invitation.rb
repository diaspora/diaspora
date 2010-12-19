#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  belongs_to :aspect

  validates_presence_of :sender, :recipient, :aspect

  def self.invite(opts = {})
    return false if opts[:email] == opts[:from].email
    existing_user = User.find_by_email(opts[:email])
    if existing_user
      if opts[:from].contact_for(opts[:from].person)
        raise "You are already connceted to this person"
      elsif not existing_user.invited?
        opts[:from].send_contact_request_to(existing_user.person, opts[:into])
        return
      elsif Invitation.first(:sender_id => opts[:from].id, :recipient_id => existing_user.id)
        raise "You already invited this person"
      end
    end
    create_invitee(opts)
  end

  def self.new_or_existing_user_by_email(email)
    existing_user = User.first(:email => email)
    if existing_user
      existing_user
    else
      result = User.new()
      result.email = email
      result.valid?
      result
    end
  end

  def self.create_invitee(opts = {})
    invitee = new_or_existing_user_by_email(opts[:email])
    return invitee unless opts[:email].match Devise.email_regexp
    invitee.invites = opts[:invites]
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
    Rails.logger.info("event=invitation_sent to=#{opts[:email]} #{"inviter=#{opts[:from].diaspora_handle}" if opts[:from]}")
    invitee
  end

  def to_request!
    request = sender.send_contact_request_to(recipient.person, aspect)
    destroy if request
    request
  end
end
