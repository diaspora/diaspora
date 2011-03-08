#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require File.join(Rails.root, 'lib/webfinger')
require File.join(Rails.root, 'lib/diaspora/parser')

module Postzord
  class Receiver
    def initialize(user, opts={})
      @user = user
      @user_person = @user.person
      @salmon_xml = opts[:salmon_xml]

      @sender = opts[:person] || Webfinger.new(self.salmon.author_email).fetch
      @author = @sender

      @object = opts[:object]
    end

    def perform
      if @sender && self.salmon.verified_for_key?(@sender.public_key)
        parse_and_receive(salmon.parsed_data)
      else
        Rails.logger.info("event=receive status=abort recipient=#{@user.diaspora_handle} sender=#{@salmon.author_email} reason='not_verified for key'")
        nil
      end
    end

    def parse_and_receive(xml)
      @object ||= Diaspora::Parser.from_xml(xml)
      Rails.logger.info("event=receive status=start recipient=#{@user_person.diaspora_handle} payload_type=#{@object.class} sender=#{@sender.diaspora_handle}")
      if self.validate_object
        receive_object
      end
    end

    def receive_object
      obj = @object.receive(@user, @author)
      Notification.notify(@user, obj, @author) if obj.respond_to?(:notification_type)
      Rails.logger.info("event=receive status=complete recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type=#{obj.class}")
      obj
    end


    protected
    def salmon
      @salmon ||= Salmon::SalmonSlap.parse(@salmon_xml, @user)
    end

    def xml_author
      if @object.respond_to?(:relayable)
        #if A and B are friends, and A sends B a comment from C, we delegate the validation to the owner of the post being commented on
        xml_author = @user.owns?(@object.parent) ? @object.diaspora_handle : @object.parent.author.diaspora_handle
        @author = Webfinger.new(@object.diaspora_handle).fetch
      else
        xml_author = @object.diaspora_handle
      end
      xml_author
    end

    def validate_object
      #begin similar
      unless @object.is_a?(Request) || @user.contact_for(@sender)
        Rails.logger.info("event=receive status=abort reason='sender not connected to recipient' recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type=#{@object.class}")
        return false
      end
            #special casey
      if @object.is_a?(Request)
        @object.sender_handle = @sender.diaspora_handle
      end

      # abort if we haven't received the post to a comment
      if @object.respond_to?(:relayable) && @object.parent.nil?
        Rails.logger.info("event=receive status=abort reason='received a comment but no corresponding post' recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type=#{@object.class})")
        return false
      end

      if (@author.diaspora_handle != xml_author)
        Rails.logger.info("event=receive status=abort reason='author in xml does not match retrieved person' payload_type=#{@object.class} recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle}")
        return false
      end

      if @author
        @object.author = @author if @object.respond_to? :author=
        @object.person = @author if @object.respond_to? :person=
      end

      @object
    end
  end
end
