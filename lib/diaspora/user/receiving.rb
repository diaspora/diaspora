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
          salmon_author.save!
          object.sender = salmon_author
        end

        if object.is_a?(Comment)
          xml_author = (owns?(object.post)) ? object.diaspora_handle : object.post.person.diaspora_handle
        else
          xml_author = object.diaspora_handle
          pp xml_author
          pp salmon_author
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
          disconnected_by Person.where(:id => retraction.post_id).first
        else
          retraction.perform self.id
          aspects = self.aspects_with_person(retraction.person)
          PostVisibility.where(:post_id => retraction.post_id,
                               :aspect_id => aspects.map{|a| a.id}).delete_all
        end
        retraction
      end

      def receive_request request, person
        Rails.logger.info("event=receive payload_type=request sender=#{request.sender} recipient=#{request.recipient}")
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

        comment.socket_to_uid(self.id, :aspect_ids => comment.post.aspect_ids)
        comment
      end

      def existing_post(post)
        post.class.where(:guid => post.guid).first
      end

      def post_visible?(post)
        raw_visible_posts.where(:guid => post.guid).first
      end

      def receive_post post
        #exsists locally, but you dont know about it
        #does not exsist locally, and you dont know about it

        #exsists_locally?
        #you know about it, and it is mutable
        #you know about it, and it is not mutable
        #
        on_pod = existing_post(post)
        log_string = "event=receive payload_type=#{post.class} sender=#{post.diaspora_handle} "
        if on_pod
          puts "On pod"
          if post_visible?(post)
            puts "visible"
            if post.mutable?
              on_pod.caption = post.caption
              on_pod.save!
            else
              Rails.logger.info(log_string << "update=true status=abort reason=immutable existing_post=#{on_pod.id}")
            end
          else
            add_post_to_aspects(on_pod)
            Rails.logger.info(log_string << "update=false status=complete")
            on_pod
          end
        else
          post.save!
          add_post_to_aspects(post)
          Rails.logger.info(log_string << "update=false status=complete")
          post
        end
      end


      def add_post_to_aspects(post)
        Rails.logger.debug("event=add_post_to_aspects user_id=#{self.id} post_id=#{post.id}")
        puts("event=add_post_to_aspects user_id=#{self.id} post_id=#{post.id}")

        aspects = self.aspects_with_person(post.person)
        aspects.each do |aspect|
          aspect.posts << post
        end
        post.socket_to_uid(id, :aspect_ids => aspects.map{|x| x.id}) if (post.respond_to?(:socket_to_uid) && !self.owns?(post))
        post
      end
    end
  end
end
