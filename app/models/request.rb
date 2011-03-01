#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Request < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/webhooks')

  require File.join(Rails.root, 'lib/postzord/dispatch')
  include Diaspora::Webhooks
  include ROXML

  xml_accessor :sender_handle
  xml_accessor :recipient_handle

  belongs_to :sender,   :class_name => 'Person'
  belongs_to :recipient, :class_name => 'Person'
  belongs_to :aspect

  validates_uniqueness_of :sender_id, :scope => :recipient_id
  validates_presence_of :sender, :recipient
  validate :not_already_connected
  validate :not_friending_yourself

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

  def notification_type(user, person)
    if Contact.where(:user_id => user.id, :person_id => person.id).first
      Notifications::RequestAccepted
    else
      Notifications::NewRequest
    end
  end

  def subscribers(user)
    [self.recipient]
  end

  def receive(user, person)
    Rails.logger.info("event=receive payload_type=request sender=#{self.sender} to=#{self.recipient}")
    user.receive_contact_request(self)
    self.save
    self
  end

  private

  def not_already_connected
    if sender && recipient && Contact.where(:user_id => self.recipient.owner_id, :person_id => self.sender.id).count > 0
      errors[:base] << 'You have already connected to this person'
    end
  end

  def not_friending_yourself
    if self.recipient == self.sender
      errors[:base] << 'You can not friend yourself'
    end
  end
end
