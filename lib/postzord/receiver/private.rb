#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Receiver::Private < Postzord::Receiver

  def initialize(user, opts={})
    @user = user
    @user_person = @user.person
    @salmon_xml = opts[:salmon_xml]

    @author = opts[:person] || Person.find_or_fetch_by_identifier(salmon.author_id)

    @object = opts[:object]
  end

  def receive!
    if @author && salmon.verified_for_key?(@author.public_key)
      parse_and_receive(salmon.parsed_data)
    else
      logger.error "event=receive status=abort reason='not_verified for key' " \
                   "recipient=#{@user.diaspora_handle} sender=#{@salmon.author_id}"
    end
  rescue => e
    logger.error "failed to receive #{@object.class} from sender:#{@author.id} for user:#{@user.id}: #{e.message}\n" \
                 "#{@object.inspect}"
    raise e
  end

  def parse_and_receive(xml)
    @object ||= Diaspora::Parser.from_xml(xml)

    logger.info "user:#{@user.id} starting private receive from person:#{@author.guid}"

    validate_object
    set_author!
    receive_object
  end

  # @return [void]
  def receive_object
    obj = @object.receive(@user, @author)
    Notification.notify(@user, obj, @author) if obj.respond_to?(:notification_type)
    logger.info "user:#{@user.id} successfully received #{@object.class} from person #{@author.guid}" \
                "#{": #{@object.guid}" if @object.respond_to?(:guid)}"
    logger.debug "received: #{@object.inspect}"
  end

  protected

  def salmon
    @salmon ||= Salmon::EncryptedSlap.from_xml(@salmon_xml, @user)
  end

  def xml_author
    if @object.respond_to?(:relayable?)
      #if A and B are friends, and A sends B a comment from C, we delegate the validation to the owner of the post being commented on
      xml_author = @user.owns?(@object.parent) ? @object.diaspora_handle : @object.parent_author.diaspora_handle
      @author = Person.find_or_fetch_by_identifier(@object.diaspora_handle) if @object.author
    else
      xml_author = @object.diaspora_handle
    end
    xml_author
  end


  def set_author!
    return unless @author
    @object.author = @author if @object.respond_to? :author=
    @object.person = @author if @object.respond_to? :person=
  end

  private

  # validations

  def validate_object
    raise Diaspora::XMLNotParseable if @object.nil?
    raise Diaspora::ContactRequiredUnlessRequest if contact_required_unless_request
    raise Diaspora::RelayableObjectWithoutParent if relayable_without_parent?

    assign_sender_handle_if_request

    raise Diaspora::AuthorXMLAuthorMismatch if author_does_not_match_xml_author?
  end

  def contact_required_unless_request
    unless @object.is_a?(Request) || @user.contact_for(@author) || (@author.owner && @author.owner.podmin_account?)
      logger.error "event=receive status=abort reason='sender not connected to recipient' type=#{@object.class} " \
                   "recipient=#{@user_person.diaspora_handle} sender=#{@author.diaspora_handle}"
      return true
    end
  end

  def assign_sender_handle_if_request
    #special casey
    if @object.is_a?(Request)
      @object.sender_handle = @author.diaspora_handle
    end
  end
end
