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
          |x| x.to == desired_friend}
        raise "You are already friends with that person!" if contact_for desired_friend
        request = Request.instantiate(
          :to => desired_friend,
          :from => self.person,
          :into => aspect)
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
        activate_friend(request.from, aspect_by_id(aspect_id))

        request.reverse_for(self)
      end

      def dispatch_friend_acceptance(request, requester)
        push_to_people request, [requester]
        request.destroy unless request.from.owner
      end

      def accept_and_respond(friend_request_id, aspect_id)
        requester = pending_requests.find!(friend_request_id).from
        reversed_request = accept_friend_request(friend_request_id, aspect_id)
        dispatch_friend_acceptance reversed_request, requester
      end

      def ignore_friend_request(friend_request_id)
        request = pending_requests.find!(friend_request_id)
        person  = request.from

        self.pending_request_ids.delete(request.id)
        self.save

        person.save
        request.destroy
      end

      def receive_friend_request(friend_request)
        Rails.logger.info("receiving friend request #{friend_request.to_json}")
        
        #response from a friend request you sent
        if original_request = original_request(friend_request)
          destination_aspect = self.aspect_by_id(original_request.into_id)
          #pp original_request
          #pp friend_request
          #pp friend_request.person
          activate_friend(friend_request.from, destination_aspect)
          Rails.logger.info("#{self.real_name}'s friend request has been accepted")

          friend_request.destroy

          pending_requests.delete(original_request)
          original_request.destroy
          self.save
          Request.send_request_accepted(self, friend_request.from, destination_aspect)

        #this is a new friend request
        elsif !request_from_me?(friend_request)
          self.pending_requests << friend_request
          self.save!
          Rails.logger.info("#{self.real_name} has received a friend request")
          friend_request.save
          Request.send_new_request(self, friend_request.from)
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
        contact.aspects.each{|aspect|
          contact.aspects.delete(aspect)
          aspect.posts.each { |post|
            aspect.post_ids.delete(post.id) if post.person == bad_friend
          }
          aspect.save
        }

        self.raw_visible_posts.find_all_by_person_id( bad_friend.id ).each{|post|
          self.visible_post_ids.delete( post.id )
          post.user_refs -= 1
          (post.user_refs > 0 || post.person.owner.nil? == false) ?  post.save : post.destroy
        }
        self.save
        raise "Friend not deleted" unless contact.destroy
        bad_friend.save
      end

      def unfriended_by(bad_friend)
        Rails.logger.info("#{self.real_name} is being unfriended by #{bad_friend.inspect}")
        remove_friend bad_friend
      end

      def activate_friend(person, aspect)
        new_contact = Contact.create!(:user => self, :person => person, :aspects => [aspect])
        new_contact.aspects << aspect
        save!
        aspect.save!
      end

      def request_from_me?(request)
        request.from == self.person
      end

      def original_request(response)
        pending_requests.first(:from_id => self.person.id, :to_id => response.from.id)
      end

      def requests_for_me
        pending_requests.select{|req| req.to == self.person} 
      end
    end
  end
end
