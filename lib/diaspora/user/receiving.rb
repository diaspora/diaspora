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

        if object.is_a?(Request)
          salmon_author.save
          object.sender_handle = salmon_author.diaspora_handle
        end

        if object.is_a?(Comment)
          xml_author = (owns?(object.post))? object.diaspora_handle : object.post.person.diaspora_handle
        else
          xml_author = object.diaspora_handle 
        end

        if (salmon_author.diaspora_handle != xml_author)
          Rails.logger.info("event=receive status=abort reason='author in xml does not match retrieved person' payload_type=#{object.class} recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle}")
          return
        end

        e = Webfinger.new(object.diaspora_handle)

        begin 
          person = e.fetch
        rescue Exception => e
          Rails.logger.info("event=receive status=abort reason='#{e.message}' payload_type=#{object.class} recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle}")
          return
        end

        if person
          object.person = person if object.respond_to? :person=

          unless object.is_a?(Request) || self.contact_for(salmon_author)
            Rails.logger.info("event=receive status=abort reason='sender not connected to recipient' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload_type=#{object.class}")
            return
          else
            receive_object(object, person)
            Rails.logger.info("event=receive status=complete recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload_type#{object.class}")

            return object
          end
        end
      end

      def receive_object(object,person)
        if object.is_a?(Request)
          obj = receive_request object, person
        elsif object.is_a?(Profile)
          obj = receive_profile object, person
        elsif object.is_a?(Comment) 
          obj = receive_comment object
        elsif object.is_a?(Retraction)
          obj = receive_retraction object
        else
          obj = receive_post object
        end
        unless object.is_a? Retraction
          Notification.notify(self, object, person)
        end
        return obj
      end

      def receive_retraction retraction
        if retraction.type == 'Person'
          unless retraction.person.id.to_s == retraction.post_id.to_s
            Rails.logger.info("event=receive status=abort reason='sender is not the person he is trying to retract' recipient=#{self.diaspora_handle} sender=#{retraction.person.diaspora_handle} payload_type=#{retraction.class} retraction_type=person")
            return
          end
          disconnected_by visible_person_by_id(retraction.post_id)
        else
          retraction.perform self
          aspects = self.aspects_with_person(retraction.person)
          aspects.each{ |aspect| aspect.post_ids.delete(retraction.post_id.to_id)
            aspect.save
          }
        end
        retraction
      end

      def receive_request request, person
        Rails.logger.info("event=receive payload_type=request sender=#{request.from} to=#{request.to}")
        receive_contact_request(request)
      end

      def receive_profile profile, person
        person.profile = profile
        person.save
        profile
      end

      def receive_comment comment

        commenter = comment.person

        unless comment.post.person == self.person || comment.verify_post_creator_signature
          Rails.logger.info("event=receive status=abort reason='comment signature not valid' recipient=#{self.diaspora_handle} sender=#{comment.post.person.diaspora_handle} payload_type=#{comment.class} post_id=#{comment.post_id}")
          return
        end

        self.visible_people = self.visible_people | [commenter]
        self.save

        commenter.save

        #sign comment as the post creator if you've been hit UPSTREAM
        if owns? comment.post
          comment.post_creator_signature = comment.sign_with_key(encryption_key)
          comment.save
        end

        #dispatch comment DOWNSTREAM, received it via UPSTREAM
        unless owns?(comment)
          comment.save
          dispatch_comment comment
        end

        comment.socket_to_uid(self, :aspect_ids => comment.post.aspect_ids)
        comment
      end

      def exsists_on_pod?(post)
        post.class.find_by_id(post.id)
      end

      def receive_post(post)
        #exsists locally, but you dont know about it
        #does not exsist locally, and you dont know about it

        #exsists_locally?
        #you know about it, and it is mutable
        #you know about it, and it is not mutable
        #
        on_pod = exsists_on_pod?(post)
        if on_pod && on_pod.diaspora_handle == post.diaspora_handle 
          known_post = find_visible_post_by_id(post.id)
          if known_post 
            if known_post.mutable?
              known_post.update_attributes(post.to_mongo)
            else
              Rails.logger.info("event=receive payload_type=#{post.class} update=true status=abort sender=#{post.diaspora_handle} reason=immutable existing_post=#{known_post.id}")
            end
          elsif on_pod == post 
            update_user_refs_and_add_to_aspects(on_pod)
            Rails.logger.info("event=receive payload_type=#{post.class} update=true status=complete sender=#{post.diaspora_handle} existing_post=#{on_pod.id}")
            post
          end
        elsif !on_pod 
          update_user_refs_and_add_to_aspects(post)
          Rails.logger.info("event=receive payload_type=#{post.class} update=false status=complete sender=#{post.diaspora_handle}")
          post
        else
          Rails.logger.info("event=receive payload_type=#{post.class} update=true status=abort sender=#{post.diaspora_handle} reason='update not from post owner' existing_post=#{post.id}")
        end
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
