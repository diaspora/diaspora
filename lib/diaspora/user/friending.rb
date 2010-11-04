#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Friending
      def send_friend_request_to(desired_friend, aspect)
        # should have different exception types for these?
        raise "You cannot befriend yourself" if desired_friend.nil? 
        raise "You have already sent a friend request to that person!" if self.pending_requests.detect{
          |x| x.destination_url == desired_friend.receive_url }
        raise "You are already friends with that person!" if self.friends.detect{
          |x| x.person.receive_url == desired_friend.receive_url}
        request = Request.instantiate(
          :to => desired_friend.receive_url,
          :from => self.person,
          :into => aspect.id)
        if request.save
          self.pending_requests << request
          self.save

          aspect.requests << request
          aspect.save
          push_to_people request, [desired_friend]
        end
        request
      end

      def accept_friend_request(friend_request_id, aspect_id)
        request = pending_requests.find!(friend_request_id)
        pending_request_ids.delete(request.id.to_id)
        activate_friend(request.person, aspect_by_id(aspect_id))

        request.reverse_for(self)
      end

      def dispatch_friend_acceptance(request, requester)
        push_to_people request, [requester]
        request.destroy unless request.callback_url.include? url
      end

      def accept_and_respond(friend_request_id, aspect_id)
        requester = pending_requests.find!(friend_request_id).person
        reversed_request = accept_friend_request(friend_request_id, aspect_id)
        dispatch_friend_acceptance reversed_request, requester
      end

      def ignore_friend_request(friend_request_id)
        request = pending_requests.find!(friend_request_id)
        person  = request.person

        self.pending_request_ids.delete(request.id)
        self.save

        person.save
        request.destroy
      end

      def receive_friend_request(friend_request)
        Rails.logger.info("receiving friend request #{friend_request.to_json}")
        
        #response from a friend request you sent
        if original_request = original_request(friend_request)
          destination_aspect = self.aspect_by_id(original_request.aspect_id)
          activate_friend(friend_request.person, destination_aspect)
          Rails.logger.info("#{self.real_name}'s friend request has been accepted")
          friend_request.destroy
          original_request.destroy
          Notifier.request_accepted(self, friend_request.person, destination_aspect)

        #this is a new friend request
        elsif !request_from_me?(friend_request)
          self.pending_requests << friend_request
          self.save
          Rails.logger.info("#{self.real_name} has received a friend request")
          friend_request.save
          Notifier.new_request(self, friend_request.person).deliver
        else
          raise "#{self.real_name} is trying to receive a friend request from himself."
        end
        friend_request
      end

      def unfriend(bad_friend)
        Rails.logger.info("#{self.real_name} is unfriending #{bad_friend.inspect}")
        retraction = Retraction.for(self)
        push_to_people retraction, [bad_friend]
        remove_friend(bad_friend)
      end

      def remove_friend(bad_friend)
        contact = contact_for(bad_friend)
        raise "Friend not deleted" unless self.friend_ids.delete(contact.id)
        contact.aspects.each{|aspect|
          contact.aspects.delete(aspect)
          aspect.posts.delete_if { |post| 
            post.person_id == bad_friend.id
          }
          aspect.save
        }

        self.raw_visible_posts.find_all_by_person_id( bad_friend.id ).each{|post|
          self.visible_post_ids.delete( post.id )
          post.user_refs -= 1
          (post.user_refs > 0 || post.person.owner.nil? == false) ?  post.save : post.destroy
        }
        self.save
        contact.destroy
        bad_friend.save
      end

      def unfriended_by(bad_friend)
        Rails.logger.info("#{self.real_name} is being unfriended by #{bad_friend.inspect}")
        remove_friend bad_friend
      end

      def activate_friend(person, aspect)
        new_contact = Contact.create(:user => self, :person => person, :aspects => [aspect])
        new_contact.aspects << aspect
        friends << new_contact
        save!
        aspect.save!
      end

      def request_from_me?(request)
        request.diaspora_handle == self.diaspora_handle
      end

      def original_request(response)
        pending_requests.find_by_destination_url(response.callback_url) unless response.nil? || response.id.nil?
      end

      def requests_for_me
        pending_requests.select{|req| req.destination_url == self.person.receive_url} 
      end
    end
  end
end
