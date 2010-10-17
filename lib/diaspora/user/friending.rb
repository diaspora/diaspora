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
          |x| x.receive_url == desired_friend.receive_url}
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
        request = Request.find_by_id(friend_request_id)
        pending_requests.delete(request)

        activate_friend(request.person, aspect_by_id(aspect_id))

        request.reverse_for(self)
        request
      end

      def dispatch_friend_acceptance(request, requester)
        friend_acceptance = salmon(request)
        push_to_person requester, friend_acceptance.xml_for(requester)
        request.destroy unless request.callback_url.include? url
      end

      def accept_and_respond(friend_request_id, aspect_id)
        requester = Request.find_by_id(friend_request_id).person
        reversed_request = accept_friend_request(friend_request_id, aspect_id)
        dispatch_friend_acceptance reversed_request, requester
      end

      def ignore_friend_request(friend_request_id)
        request = Request.find_by_id(friend_request_id)
        person  = request.person

        self.pending_requests.delete(request)
        self.save

        person.save
        request.destroy
      end

      def receive_friend_request(friend_request)
        Rails.logger.info("receiving friend request #{friend_request.to_json}")

        if request_from_me?(friend_request) && self.aspect_by_id(friend_request.aspect_id)
          aspect = self.aspect_by_id(friend_request.aspect_id)
          activate_friend(friend_request.person, aspect)

          Rails.logger.info("#{self.real_name}'s friend request has been accepted")

          friend_request.destroy
        else
          self.pending_requests << friend_request
          self.save
          Rails.logger.info("#{self.real_name} has received a friend request")
          friend_request.save
        end
      end

      def unfriend(bad_friend)
        Rails.logger.info("#{self.real_name} is unfriending #{bad_friend.inspect}")
        retraction = Retraction.for(self)
        push_to_people retraction, [bad_friend]
        remove_friend(bad_friend)
      end

      def remove_friend(bad_friend)
        raise "Friend not deleted" unless self.friend_ids.delete( bad_friend.id )
        aspects.each{|aspect|
          aspect.person_ids.delete( bad_friend.id )}
        self.save

        self.raw_visible_posts.find_all_by_person_id( bad_friend.id ).each{|post|
          self.visible_post_ids.delete( post.id )
          post.user_refs -= 1
          (post.user_refs > 0 || post.person.owner.nil? == false) ?  post.save : post.destroy
        }
        self.save

        bad_friend.save
      end

      def unfriended_by(bad_friend)
        Rails.logger.info("#{self.real_name} is being unfriended by #{bad_friend.inspect}")
        remove_friend bad_friend
      end

      def activate_friend(person, aspect)
        aspect.people << person
        friends << person
        save
        aspect.save
      end

      def request_from_me?(request)
        (pending_request_ids.include?(request.id.to_id)) && (request.callback_url == person.receive_url) 
      end

      def requests_for_me
        pending_requests.select{|req| req.person != self.person }
      end
    end
  end
end
