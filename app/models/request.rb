#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Request < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/webhooks')

  include Diaspora::Webhooks
  include ROXML

  #xml_reader :sender_handle
  #xml_reader :recipient_handle

  belongs_to :sender,   :class_name => 'Person'
  belongs_to :recipient, :class_name => 'Person'
  belongs_to :aspect

  validates_presence_of :sender, :recipient
  validate :not_already_connected
  validate :not_friending_yourself

  scope :from, lambda { |person|
    target = (person.is_a?(User) ? person.person : person)
    where(:sender_id => target.id)
  }

  scope :to, lambda { |person|
    target = (person.is_a?(User) ? person.person : person)
    where(:recipient_id => target.id)
  }


  def self.diaspora_initialize(opts = {})
    self.new(:sender => opts[:from],
             :recipient   => opts[:to],
             :aspect => opts[:into])
  end

  def reverse_for accepting_user
    Request.new(
      :sender => accepting_user.person,
      :recipient => self.sender
    )
  end

  def sender_handle
    sender.diaspora_handle
  end

  def sender_handle= sender_handle
    self.sender = Person.where(:diaspora_handle => sender_handle).first
  end

  def recipient_handle
    recipient.diaspora_handle
  end

  def recipient_handle= recipient_handle
    self.recipient = Person.where(:diaspora_handle => recipient_handle).first
  end

  def diaspora_handle
    sender_handle
  end

  def self.hashes_for_person person
    requests = Request.to(person).all
    senders = Person.all(:id.in => requests.map{|r| r.from_id})
    senders_hash = {}
    senders.each{|sender| senders_hash[sender.id] = sender}
    requests.map{|r| {:request => r, :sender => senders_hash[r.from_id]}}
  end


  def notification_type(user, person)
    if Contact.where(:user_id => user.id, :person_id => person.id).first
      "request_accepted"
    else
      "new_request"
    end
  end

  private

  def not_already_connected
    if sender && recipient && Contact.where(:user_id => self.sender.owner_id, :person_id => self.recipient.id).count > 0
      errors[:base] << 'You have already connected to this person'
    end
  end

  def not_friending_yourself
    if self.recipient == self.sender
      errors[:base] << 'You can not friend yourself'
    end
  end
end
