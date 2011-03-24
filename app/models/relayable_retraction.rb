#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RelayableRetraction
  include ROXML
  include Diaspora::Webhooks

  xml_attr :target_guid
  xml_attr :target_type
  xml_attr :sender_handle
  xml_attr :parent_author_signature
  xml_attr :target_author_signature

  attr_accessor :target_guid,
                :target_type,
                :parent_author_signature,
                :target_author_signature,
                :sender

  def sender_handle= new_sender_handle
    @sender = Person.where(:diaspora_handle => new_sender_handle).first
  end

  def sender_handle
    @sender.diaspora_handle
  end

  def subscribers(user)
    @subscribers ||= self.target.subscribers(user)
  end

  def self.initialize(sender, target)
    self.sender = sender
    self.target = target
  end

  def target
    @target ||= self.target_type.constantize.where(:guid => target_guid).first
  end

  def target= new_target
    @target = new_target
    @target_type = new_target.class.to_s
    @target_guid = new_target.guid
  end

  def parent
    self.target.parent
  end

  def parent_class
    self.target.parent_class
  end

  def perform receiving_user
    Rails.logger.debug "Performing retraction for #{target_guid}"
    self.target.unsocket_from_user receiving_user if target.respond_to? :unsocket_from_user
    self.target.destroy
    target.post_visibilities.delete_all
    Rails.logger.info("event=retraction status=complete target_type=#{self.target_type} guid=#{self.target_guid}")
  end

  def receive(recipient, sender)
    if self.parent.author == recipient.person && self.target_author_signature_valid?
      #this is a retraction from the downstream object creator, and the recipient is the upstream owner
      self.parent_author_signature = self.sign_with_key(recipient.encryption_key)
      Postzord::Dispatch.new(recipient, self).post
      self.perform(recipient)
    elsif self.parent_author_signature_valid?
      #this is a retraction from the upstream owner
      self.perform(recipient)
    else
      Rails.logger.info("event=receive status=abort reason='object signature not valid' recipient=#{recipient.diaspora_handle} sender=#{self.parent.author.diaspora_handle} payload_type=#{self.class} parent_id=#{self.parent.id}")
      return
    end
    self
  end

  def parent_author_signature_valid?
    verify_signature(self.parent_author_signature, self.parent.author)
  end

  def target_author_signature_valid?
    verify_signature(self.target_author_signature, self.author)
  end
end
