#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join('lib', 'webfinger')
require Rails.root.join('lib', 'diaspora', 'parser')

class Postzord::Receiver::Private < Postzord::Receiver

  def initialize(user, opts={})
    @user = user
    @user_person = @user.person
    @salmon_xml = opts[:salmon_xml]

    @sender = opts[:person] || Webfinger.new(self.salmon.author_id).fetch
    @author = @sender

    @object = opts[:object]
  end

  def receive!
    begin 
      if @sender && self.salmon.verified_for_key?(@sender.public_key)
        parse_and_receive(salmon.parsed_data)
      else
        FEDERATION_LOGGER.info("event=receive status=abort recipient=#{@user.diaspora_handle} sender=#{@salmon.author_id} reason='not_verified for key'")
        false
      end
    rescue => e
      #this sucks
      FEDERATION_LOGGER.error("Failure to receive #{@object.class} from sender:#{@sender.id} for user:#{@user.id}: #{e.message}\n#{@object.inspect}")
      raise e
    end
  end

  def parse_and_receive(xml)
    @object ||= Diaspora::Parser.from_xml(xml)
    return  if @object.nil?

    FEDERATION_LOGGER.info("user:#{@user.id} starting private receive from person:#{@sender.guid}")

    if self.validate_object
      set_author!
      receive_object
      FEDERATION_LOGGER.info("object received: [#{@object.class}#{@object.respond_to?(:text) ? ":'#{@object.text}'" : ''}]")
    else
      FEDERATION_LOGGER.error("failed to receive object from #{@object.author}: #{@object.inspect}")
      raise "not a valid object:#{@object.inspect}"
    end
  end

  # @return [Object]
  def receive_object
    obj = @object.receive(@user, @author)
    Notification.notify(@user, obj, @author) if obj.respond_to?(:notification_type)
    FEDERATION_LOGGER.info("user:#{@user.id} successfully received private post from person #{@sender.guid}: #{@object.inspect}")
    obj
  end

  protected
  def salmon
    @salmon ||= Salmon::EncryptedSlap.from_xml(@salmon_xml, @user)
  end

  def validate_object
    raise "Contact required unless request" if contact_required_unless_request
    raise "Relayable object, but no parent object found" if relayable_without_parent?

    assign_sender_handle_if_request

    raise "Author does not match XML author" if author_does_not_match_xml_author?

    @object
  end

  def xml_author
    if @object.respond_to?(:relayable?)
      #if A and B are friends, and A sends B a comment from C, we delegate the validation to the owner of the post being commented on
      xml_author = @user.owns?(@object.parent) ? @object.diaspora_handle : @object.parent_author.diaspora_handle
      @author = Webfinger.new(@object.diaspora_handle).fetch if @object.author
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

  #validations
  def relayable_without_parent?
    if @object.respond_to?(:relayable?) && @object.parent.nil?
      FEDERATION_LOGGER.error("event=receive status=abort reason='received a comment but no corresponding post' recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type=#{@object.class})")
      return true
    end
  end

  def contact_required_unless_request
    unless @object.is_a?(Request) || @user.contact_for(@sender)
      FEDERATION_LOGGER.error("event=receive status=abort reason='sender not connected to recipient' recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle}")
      return true 
    end
  end

  def assign_sender_handle_if_request
    #special casey
    if @object.is_a?(Request)
      @object.sender_handle = @sender.diaspora_handle
    end
  end
end
