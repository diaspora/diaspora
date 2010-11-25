require File.join(Rails.root, 'lib/em-webfinger')

module Diaspora
  module UserModules
    module Receiving
      def receive_salmon salmon_xml
        salmon = Salmon::SalmonSlap.parse salmon_xml, self
        webfinger = EMWebfinger.new(salmon.author_email)

        webfinger.on_person { |response|
          if response.is_a? Person
            salmon_author = response
            if salmon.verified_for_key?(salmon_author.public_key)
              Rails.logger.info("data in salmon: #{salmon.parsed_data}")
              self.receive(salmon.parsed_data, salmon_author)
            end
          else
            Rails.logger.info("#{salmon.author_email} not found error: #{response}")
          end
        }
      end

      def receive xml, salmon_author
        object = Diaspora::Parser.from_xml(xml)
        Rails.logger.info("event=receive status=start recipient=#{self.diaspora_handle} object=#{object.inspect} sender=#{salmon_author.diaspora_handle}")
        
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
          Rails.logger.info("event=receive status=abort reason='author in xml does not match retrieved person' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload=#{object.inspect}")
          return
        end

        e = EMWebfinger.new(object.diaspora_handle)

        e.on_person do |person|
          if person.class == Person
            object.person = person if object.respond_to? :person=
            unless object.is_a?(Request) || self.contact_for(salmon_author)
              Rails.logger.info("event=receive status=abort reason='sender not connected to recipient' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload=#{object.inspect}")
              return
            else
              receive_object(object,person)
              Rails.logger.info("event=receive status=complete recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload=#{object.inspect}")
              return
            end
          end
        end
      end

      def receive_object(object,person)
        if object.is_a?(Request)
          receive_request object, person
        elsif object.is_a?(Profile)
          receive_profile object, person

        elsif object.is_a?(Comment) 
          receive_comment object
        elsif object.is_a?(Retraction)
          receive_retraction object
        else
          receive_post object
        end
      end

      def receive_retraction retraction
        if retraction.type == 'Person'
          unless retraction.person.id.to_s == retraction.post_id.to_s
            Rails.logger.info("event=receive status=abort reason='sender is not the person he is trying to retract' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload=#{retraction.inspect}")
            return
          end
          Rails.logger.info( "the person id is #{retraction.post_id} the contact found is #{visible_person_by_id(retraction.post_id).inspect}")
          disconnected_by visible_person_by_id(retraction.post_id)
        else
          retraction.perform self.id
          aspects = self.aspects_with_person(retraction.person)
          aspects.each{ |aspect| aspect.post_ids.delete(retraction.post_id.to_id)
            aspect.save
          }
        end
        retraction
      end

      def receive_request request, person
        request.save!
        receive_contact_request(request)
        request
      end

      def receive_profile profile, person
        person.profile = profile
        person.save
        profile
      end

      def receive_comment comment
        unless comment.post.person == self.person || comment.verify_post_creator_signature
          Rails.logger.info("event=receive status=abort reason='comment signature not valid' recipient=#{self.diaspora_handle} sender=#{salmon_author.diaspora_handle} payload=#{retraction.inspect}")
          return
        end
        self.visible_people = self.visible_people | [comment.person]
        self.save
        Rails.logger.debug("The person parsed from comment xml is #{comment.person.inspect}") unless comment.person.nil?
        comment.person.save
        Rails.logger.debug("From: #{comment.person.inspect}") if comment.person
        comment.save!
        unless owns?(comment)
          dispatch_comment comment
        end
        comment.socket_to_uid(id)  if (comment.respond_to?(:socket_to_uid) && !self.owns?(comment))
        comment
      end

      def exsists_on_pod?(post)
        post.class.find_by_id(post.id)
      end

      def receive_post post
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
              Rails.logger.info("#{post.diaspora_handle} is trying to update an immutable object #{known_post.inspect}")
            end
          elsif on_pod == post 
            update_user_refs_and_add_to_aspects(on_pod)
          end
        elsif !on_pod 
          update_user_refs_and_add_to_aspects(post)
        else
          Rails.logger.info("#{post.diaspora_handle} is trying to update an exsisting object they do not own #{on_pod.inspect}")
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
        post.socket_to_uid(id, :aspect_ids => aspects.map{|x| x.id}) if (post.respond_to?(:socket_to_uid) && !self.owns?(post))
        post
      end
    end
  end
end
