require File.join(Rails.root, 'lib/webfinger')
require File.join(Rails.root, 'lib/diaspora/parser')

module Diaspora
  module UserModules
    module Receiving
      def receive_salmon salmon_xml
        salmon = Salmon::SalmonSlap.parse salmon_xml, self
        webfinger = Webfinger.new(salmon.author_email)
        begin
          salmon_author = webfinger.fetch
        rescue Exception => e
          Rails.logger.info("event=receive status=abort recipient=#{self.diaspora_handle} sender=#{salmon.author_email} reason='#{e.message}'")
        end
        
        if salmon.verified_for_key?(salmon_author.public_key)
          self.receive(salmon.parsed_data, salmon_author)
        else
          Rails.logger.info("event=receive status=abort recipient=#{self.diaspora_handle} sender=#{salmon.author_email} reason='not_verified for key'")
        end
      end

      def receive xml, salmon_author
        object = Diaspora::Parser.from_xml(xml)
        Rails.logger.info("event=receive status=start recipient=#{self.diaspora_handle} payload_type=#{object.class} sender=#{salmon_author.diaspora_handle}")

        #special casey
        if object.is_a?(Request)
          object.sender_handle = salmon_author.diaspora_handle
        end
        if object.is_a?(Comment)
          xml_author = (owns?(object.post))? object.diaspora_handle : object.post.person.diaspora_handle
          person = Webfinger.new(object.diaspora_handle).fetch
        else
          xml_author = object.diaspora_handle 
          person = salmon_author
        end

        #begin similar
        unless object.is_a?(Request) || self.contact_for(salmon_author)
          Rails.logger.info("event=receive status=abort reason='sender not connected to recipient' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload_type=#{object.class}")
          return
        end

        if (salmon_author.diaspora_handle != xml_author)
          Rails.logger.info("event=receive status=abort reason='author in xml does not match retrieved person' payload_type=#{object.class} recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle}")
          return
        end

        if person
          Rails.logger.info("event=receive status=complete recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload_type#{object.class}")

          object.person = person if object.respond_to? :person=
          receive_object(object, person)
        end
      end

      def receive_object(object,person)
        obj = object.receive(self, person)
        Notification.notify(self, object, person) unless object.is_a? Retraction
        obj
      end

      def update_user_refs_and_add_to_aspects(post)
        Rails.logger.debug("Saving post: #{post}")
        post.user_refs += 1
        post.save

        self.raw_visible_posts << post
        self.save

        aspects = self.aspects_with_person(post.person)
        aspects.each do |aspect|
          aspect.posts << post
          aspect.save
        end
        post.socket_to_uid(self, :aspect_ids => aspects.map{|x| x.id}) if (post.respond_to?(:socket_to_uid) && !self.owns?(post))
        post
      end
    end
  end
end
