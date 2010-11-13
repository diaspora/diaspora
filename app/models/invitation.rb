#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation
  include MongoMapper::Document

  belongs_to :from, :class => User
  belongs_to :to, :class => User
  belongs_to :into, :class => Aspect
  key :message, String

  validates_presence_of :from, :to, :into

  def self.invite(opts = {})
    existing_user = User.find_by_email(opts[:email])
    if existing_user
      if opts[:from].contact_for(opts[:from].person)
        raise "You are already connceted to this person"
      elsif not existing_user.invited?
        opts[:from].send_contact_request_to(existing_user.person, opts[:into])
        return
      elsif Invitation.first(:from_id => opts[:from].id, :to_id => existing_user.id)
        raise "You already invited this person"
      end
    end

    invited_user = create_invitee(:email => opts[:email])
    if invited_user.persisted?
      Invitation.create!(:from => opts[:from],
                         :to => invited_user,
                         :into => opts[:into],
                         :message => opts[:message])

      opts[:from].invites -= 1
      opts[:from].save!
      invited_user
    else
      false
    end
  end

  def self.create_invitee(opts = {})
    invitable = User.find_or_initialize_with_error_by(:email, opts[:email])

    if invitable.new_record?
      invitable.errors.clear if invitable.email.try(:match, Devise.email_regexp)
    else
      invitable.errors.add(:email, :taken) unless invitable.invited?
    end

    invitable.invite! if invitable.errors.empty?
    invitable
  end

  def to_request!
    request = from.send_contact_request_to(to.person, into)
    destroy if request
    request
  end
end
