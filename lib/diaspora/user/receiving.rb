module Diaspora
  module UserModules
    module Receiving
      def receive_salmon salmon_xml
        salmon = Salmon::SalmonSlap.parse salmon_xml, self
        if salmon.verified_for_key?(salmon.author.public_key)
          Rails.logger.info("data in salmon: #{salmon.parsed_data}")
          self.receive(salmon.parsed_data, salmon.author)
        end
      end

      def receive xml, salmon_author
        object = Diaspora::Parser.from_xml(xml)
        Rails.logger.debug("Receiving object for #{self.real_name}:\n#{object.inspect}")
        Rails.logger.debug("From: #{object.person.inspect}") if object.person


        sender_in_xml = sender(object, xml)

        if (salmon_author == sender_in_xml)
          if object.is_a? Retraction
            receive_retraction object, xml
          elsif object.is_a? Request
            receive_request object, xml
          elsif object.is_a? Profile
            receive_profile object, xml
          elsif object.is_a?(Comment)
            receive_comment object, xml
          else
            receive_post object, xml
          end
        else
          raise "Possibly Malicious Post, #{salmon_author.real_name} with id #{salmon_author.id} is sending a #{object.class} as #{sender_in_xml.real_name} with id #{sender_in_xml.id} "
        end
      end

      def sender(object, xml)
        if object.is_a? Retraction
          sender = object.person
        elsif object.is_a? Request
          sender = Diaspora::Parser.parse_or_find_person_from_xml( xml )
        elsif object.is_a? Profile
          sender = Diaspora::Parser.owner_id_from_xml xml
        elsif object.is_a?(Comment)
          sender = (owns?(object.post))? object.person : object.post.person
        else
          sender = object.person
        end
        sender
      end

      def receive_retraction retraction, xml
        if retraction.type == 'Person'
          Rails.logger.info( "the person id is #{retraction.post_id} the friend found is #{visible_person_by_id(retraction.post_id).inspect}")
          unfriended_by visible_person_by_id(retraction.post_id)
        else
          retraction.perform self.id
          aspects = self.aspects_with_person(retraction.person)
          aspects.each{ |aspect| aspect.post_ids.delete(retraction.post_id.to_id)
            aspect.save
          }
        end
      end

      def receive_request request, xml
        person = Diaspora::Parser.parse_or_find_person_from_xml( xml )
        person.serialized_public_key ||= request.exported_key
        request.person = person
        request.person.save
        old_request =  Request.first(:id => request.id)
        request.aspect_id = old_request.aspect_id if old_request
        request.save
        receive_friend_request(request)
      end

      def receive_profile profile, xml
        person = Diaspora::Parser.owner_id_from_xml xml
        person.profile = profile
        person.save
      end

      def receive_comment comment, xml
        comment.person = Diaspora::Parser.parse_or_find_person_from_xml( xml ).save if comment.person.nil?
        self.visible_people = self.visible_people | [comment.person]
        self.save
        Rails.logger.debug("The person parsed from comment xml is #{comment.person.inspect}") unless comment.person.nil?
        comment.person.save
        Rails.logger.debug("From: #{comment.person.inspect}") if comment.person
        raise "In receive for #{self.real_name}, signature was not valid on: #{comment.inspect}" unless comment.post.person == self.person || comment.verify_post_creator_signature
        comment.save
        unless owns?(comment)
          dispatch_comment comment
        end
        comment.socket_to_uid(id)  if (comment.respond_to?(:socket_to_uid) && !self.owns?(comment))
      end

      def receive_post post, xml
        Rails.logger.debug("Saving post: #{post}")
        post.user_refs += 1
        post.save

        self.raw_visible_posts << post
        self.save

        aspects = self.aspects_with_person(post.person)
        aspects.each{ |aspect|
          aspect.posts << post
          aspect.save
          post.socket_to_uid(id, :aspect_ids => [aspect.id]) if (post.respond_to?(:socket_to_uid) && !self.owns?(post))
        }
      end
    end
  end
end
