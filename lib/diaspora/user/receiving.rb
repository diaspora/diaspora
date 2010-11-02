require File.join(Rails.root, 'lib/em-webfinger')

module Diaspora
  module UserModules
    module Receiving
      def receive_salmon salmon_xml
        salmon = Salmon::SalmonSlap.parse salmon_xml, self
        webfinger = EMWebfinger.new(salmon.author_email)

        webfinger.on_person { |salmon_author|
          if salmon.verified_for_key?(salmon_author.public_key)
            Rails.logger.info("data in salmon: #{salmon.parsed_data}")
            self.receive(salmon.parsed_data, salmon_author)
          end
        }
      end

      def receive xml, salmon_author
        object = Diaspora::Parser.from_xml(xml)
        Rails.logger.debug("Receiving object for #{self.real_name}:\n#{object.inspect}")
        Rails.logger.debug("From: #{object.diaspora_handle}")
              
        if object.is_a?(Comment) 
          xml_author = (owns?(object.post))? object.diaspora_handle : object.post.person.diaspora_handle
        else
          xml_author = object.diaspora_handle 
        end

        if (salmon_author.diaspora_handle != xml_author)
          raise "Malicious Post, #{salmon_author.real_name} with id #{salmon_author.id} is sending a #{object.class} as #{xml_author} "
        end

        if object.is_a?(Comment) || object.is_a?(Post)|| object.is_a?(Request) || object.is_a?(Retraction) || object.is_a?(Profile) 
          e = EMWebfinger.new(object.diaspora_handle)

          e.on_person { |person|

            if person.class == Person
              object.person = person if object.respond_to? :person=

              if object.is_a? Request
                return receive_request object, person
              end

              raise "Not friends with that person" unless self.contact_for(salmon_author)

              if object.is_a?(Comment) 
                receive_comment object, xml
              elsif object.is_a?(Retraction)
                receive_retraction object, xml
              elsif object.is_a?(Profile)
                receive_profile object, person
              else
                receive_post object, xml
              end
            end
          }
        else
          raise "you messed up"
        end
      end

      def receive_retraction retraction, xml
        if retraction.type == 'Person'
          unless retraction.person.id.to_s == retraction.post_id.to_s
            raise "#{retraction.diaspora_handle} trying to unfriend #{retraction.post_id} from #{self.id}"
          end
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

      def receive_request request, person
        request.person = person
        request.person.save!
        old_request =  Request.find(request.id)
        Rails.logger.info("I got a reqest_id #{request.id} with old request #{old_request.inspect}")
        request.aspect_id = old_request.aspect_id if old_request
        request.save
        receive_friend_request(request)
      end

      def receive_profile profile, person
        person.profile = profile
        person.save
      end

      def receive_comment comment, xml
        raise "In receive for #{self.real_name}, signature was not valid on: #{comment.inspect}" unless comment.post.person == self.person || comment.verify_post_creator_signature
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
