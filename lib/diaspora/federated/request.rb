#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   t
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Request
  include Diaspora::Federated::Base
  include ActiveModel::Validations

  attr_accessor :sender, :recipient, :aspect

  xml_accessor :sender_handle
  xml_accessor :recipient_handle

  validates :sender, :presence => true
  validates :recipient, :presence => true

  validate :not_already_connected
  validate :not_friending_yourself

  # Initalize variables
  # @note we should be using ActiveModel::Serialization for this
  # @return [Request]
  def self.diaspora_initialize(opts = {})
    req = self.new
    req.sender = opts[:from]
    req.recipient = opts[:to]
    req.aspect = opts[:into]
    req
  end

  # Alias of sender_handle
  # @return [String]
  def diaspora_handle
    sender_handle
  end

  # @note Used for XML marshalling
  # @return [String]
  def sender_handle
    sender.diaspora_handle
  end
  def sender_handle= sender_handle
    self.sender = Person.where(:diaspora_handle => sender_handle).first
  end

  # @note Used for XML marshalling
  # @return [String]
  def recipient_handle
    recipient.diaspora_handle
  end
  def recipient_handle= recipient_handle
    self.recipient = Person.where(:diaspora_handle => recipient_handle).first
  end

  # Defines the abstract interface used in sending a corresponding [Notification] given the [Request]
  # @param user [User]
  # @param person [Person]
  # @return [Notifications::StartedSharing]
  def notification_type(user, person)
    Notifications::StartedSharing
  end

  # Defines the abstract interface used in sending the [Request]
  # @param user [User]
  # @return [Array<Person>] The recipient of the request
  def subscribers(user)
    [self.recipient]
  end

  # Finds or initializes a corresponding [Contact], and will set Contact#sharing to true
  # Follows back if user setting is set so
  # @note A [Contact] may already exist if the [Request]'s recipient is sharing with the sender
  # @return [Request]
  def receive(user, person)
    Rails.logger.info("event=receive payload_type=request sender=#{self.sender} to=#{self.recipient}")

    contact = user.contacts.find_or_initialize_by(person_id: self.sender.id)
    contact.sharing = true
    contact.save

    user.share_with(person, user.auto_follow_back_aspect) if user.auto_follow_back && !contact.receiving

    self
  end

  private

  # Checks if a [Contact] does not already exist between the requesting [User] and receiving [Person]
  def not_already_connected
    if sender && recipient && Contact.where(:user_id => self.recipient.owner_id, :person_id => self.sender.id).exists?
      errors[:base] << 'You have already connected to this person'
    end
  end

  # Checks to see that the requesting [User] is not sending a request to himself
  def not_friending_yourself
    if self.recipient == self.sender
      errors[:base] << 'You can not friend yourself'
    end
  end
end
