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
      if self.valid_object?
        receive_object
      end
    end

    def receive_object
      obj = @object.receive(@user, @author)
      Notification.notify(@user, @object, @author) unless @object.is_a?(Retraction)
      obj
    end

    def salmon
      @salmon ||= Salmon::SalmonSlap.parse(@salmon_xml, @user)
    end


    protected
    def valid_object?
      Rails.logger.info("event=receive status=start recipient=#{@user_person.diaspora_handle} payload_type=#{@object.class} sender=#{@sender.diaspora_handle}")

      #special casey
      if @object.is_a?(Request)
        @object.sender_handle = @sender.diaspora_handle
      end
      if @object.is_a?(Comment)
        xml_author = (@user.owns?(@object.post))? @object.diaspora_handle : @object.post.person.diaspora_handle
        @author = Webfinger.new(@object.diaspora_handle).fetch
      else
        xml_author = @object.diaspora_handle
      end

      #begin similar
      unless @object.is_a?(Request) || @user.contact_for(@sender)
        Rails.logger.info("event=receive status=abort reason='sender not connected to recipient' recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type=#{@object.class}")
        return false
      end

      if (@author.diaspora_handle != xml_author)
        Rails.logger.info("event=receive status=abort reason='author in xml does not match retrieved person' payload_type=#{@object.class} recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle}")
        return false
      end

      if @author
        Rails.logger.info("event=receive status=complete recipient=#{@user_person.diaspora_handle} sender=#{@sender.diaspora_handle} payload_type#{@object.class}")

        @object.person = @author if @object.respond_to? :person=
      end
      @object
    end
  end
end
