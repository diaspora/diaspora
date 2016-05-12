#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
class RelayableRetraction < SignedRetraction
  xml_name :relayable_retraction
  xml_attr :parent_author_signature

  attr_accessor :parent_author_signature

  delegate :parent, :parent_author, to: :target, allow_nil: true

  def signable_accessors
    super - ['parent_author_signature']
  end

  # @param sender [User]
  # @param target [Object]
  def self.build(sender, target)
    retraction = super
    retraction.parent_author_signature = retraction.sign_with_key(sender.encryption_key) if defined?(target.parent) && sender.person == target.parent.author
    retraction
  end

  def diaspora_handle
    self.sender_handle
  end

  def relayable?
    true
  end

  def perform receiving_user
    logger.debug "Performing relayable retraction for #{target_guid}"
    if not self.parent_author_signature.nil? or self.parent.author.remote?
      # Don't destroy a relayable unless the top-level owner has received it, otherwise it may not get relayed
      self.target.destroy
      logger.info "event=relayable_retraction status=complete target_type=#{target_type} guid=#{target_guid}"
    end
  end

  def parent_author_signature_valid?
    verify_signature(self.parent_author_signature, self.parent.author)
  end

  def parent_diaspora_handle
    target.author.diaspora_handle
  end
end
