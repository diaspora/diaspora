#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SignedRetraction
  include Diaspora::Federated::Base

  include Diaspora::Encryptable

  xml_name :signed_retraction
  xml_attr :target_guid
  xml_attr :target_type
  xml_attr :sender_handle
  xml_attr :target_author_signature

  attr_accessor :target_guid,
                :target_type,
                :target_author_signature,
                :sender

  # NOTE(fix this hack -- go through the app and make sure we only call RelayableRetraction in a unified way)
  def author
    if sender.is_a?(User)
      sender.person
    else
      sender
    end
  end

  def signable_accessors
    accessors = self.class.roxml_attrs.collect(&:accessor)
    accessors - %w(target_author_signature sender_handle)
  end

  def sender_handle=(new_sender_handle)
    @sender = Person.where(diaspora_handle: new_sender_handle).first
  end

  def sender_handle
    @sender.diaspora_handle
  end

  def diaspora_handle
    sender_handle
  end

  delegate :subscribers, to: :target

  def self.build(sender, target)
    retraction = new
    retraction.sender = sender
    retraction.target = target
    retraction.target_author_signature = retraction.sign_with_key(sender.encryption_key) if sender.person == target.author
    retraction
  end

  def target
    @target ||= target_type.constantize.where(guid: target_guid).first
  end

  def guid
    target_guid
  end

  def target=(new_target)
    @target = new_target
    @target_type = new_target.class.to_s
    @target_guid = new_target.guid
  end

  def perform(receiving_user)
    Rails.logger.debug "Performing retraction for #{target_guid}"
    if reshare = Reshare.where(author_id: receiving_user.person.id, root_guid: target_guid).first
      onward_retraction = dup
      onward_retraction.sender = receiving_user.person
      Postzord::Dispatcher.build(receiving_user, onward_retraction).post
    end
    if target && !target.destroyed?
      target.destroy
    end
    Rails.logger.info("event=retraction status =complete target_type=#{target_type} guid =#{target_guid}")
  end

  def receive(recipient, sender)
    if target.nil?
      Rails.logger.info("event=retraction status=abort reason='no post found' sender=#{sender.diaspora_handle} target_guid=#{target_guid}")
      return
    elsif self.target_author_signature_valid?
      # this is a retraction from the upstream owner
      perform(recipient)
    else
      Rails.logger.info("event=receive status=abort reason='object signature not valid' recipient=#{recipient.diaspora_handle} sender=#{sender_handle} payload_type=#{self.class}")
      return
    end
    self
  end

  def target_author_signature_valid?
    verify_signature(target_author_signature, target.author)
  end
end
