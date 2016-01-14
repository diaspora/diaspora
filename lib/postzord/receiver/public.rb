#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Receiver::Public < Postzord::Receiver

  attr_accessor :salmon, :author

  def initialize(xml)
    @salmon = Salmon::Slap.from_xml(xml)
    @author = Person.find_or_fetch_by_identifier(@salmon.author_id)
  end

  # @return [Boolean]
  def verified_signature?
    @salmon.verified_for_key?(@author.public_key)
  end

  # @return [void]
  def receive!
    return unless verified_signature?
    # return false unless account_deletion_is_from_author

    parse_and_receive(@salmon.parsed_data)

    logger.info "received a #{@object.inspect}"
    if @object.is_a?(SignedRetraction) || @object.is_a?(Retraction) # feels like a hack
      self.recipient_user_ids.each do |user_id|
        user = User.where(id: user_id).first
        @object.perform user if user
      end
    elsif @object.respond_to?(:relayable?)
      receive_relayable
    elsif @object.is_a?(AccountDeletion)
      #nothing
    else
      Workers::ReceiveLocalBatch.perform_async(@object.class.to_s, @object.id, self.recipient_user_ids)
    end
  end

  # @return [void]
  def receive_relayable
    if @object.parent_author.local?
      # receive relayable object only for the owner of the parent object
      @object.receive(@object.parent_author.owner, @author)
    end
    unless @object.signature_valid?
      @object.destroy
      logger.warn "event=receive status=abort reason='object signature not valid' "
      return
    end
    # notify everyone who can see the parent object
    receiver = Postzord::Receiver::LocalBatch.new(@object, self.recipient_user_ids)
    receiver.notify_users
  end

  # @return [void]
  def parse_and_receive(xml)
    @object = Diaspora::Parser.from_xml(xml)

    logger.info "starting public receive from person:#{@author.guid}"

    validate_object
    receive_object
  end

  # @return [void]
  def receive_object
    if @object.respond_to?(:receive_public)
      @object.receive_public
    elsif @object.respond_to?(:save!)
      @object.save!
    end
  end

  # @return [Array<Integer>] User ids
  def recipient_user_ids
    User.all_sharing_with_person(@author).pluck('users.id')
  end

  def xml_author
    if @object.is_a?(RelayableRetraction)
      if [@object.parent_diaspora_handle, @object.target.parent.diaspora_handle].include?(@author.diaspora_handle)
        @author.diaspora_handle
      end
    elsif @object.respond_to?(:relayable?)
      #this is public, so it would only be owners sending us other people comments etc
      @object.parent_author.local? ? @object.diaspora_handle : @object.parent_diaspora_handle
    else
      @object.diaspora_handle
    end
  end

  private

  # validations

  def validate_object
    raise Diaspora::XMLNotParseable if @object.nil?
    raise Diaspora::NonPublic if object_can_be_public_and_it_is_not?
    raise Diaspora::RelayableObjectWithoutParent if relayable_without_parent?
    raise Diaspora::AuthorXMLAuthorMismatch if author_does_not_match_xml_author?
  end

  def account_deletion_is_from_author
    return true unless @object.is_a?(AccountDeletion)
    return false if @object.diaspora_handle != @author.diaspora_handle
    return true
  end

  # @return [Boolean]
  def object_can_be_public_and_it_is_not?
    @object.respond_to?(:public) && !@object.public?
  end
end
