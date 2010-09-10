module Diaspora
  module UserModules
    module Friending
      def send_friend_request_to(desired_friend, group)
        raise "You are already friends with that person!" if self.friends.detect{
          |x| x.receive_url == desired_friend.receive_url}
        request = Request.instantiate(
          :to => desired_friend.receive_url,
          :from => self.person,
          :into => group.id)
        if request.save
          self.pending_requests << request
          self.save

          group.requests << request
          group.save
          
          salmon request, :to => desired_friend
        end
        request
      end
       

      def accept_friend_request(friend_request_id, group_id)
        request = Request.find_by_id(friend_request_id)
        pending_requests.delete(request)
        
        activate_friend(request.person, group_by_id(group_id))

        request.reverse_for(self)
        request
      end
      
      def dispatch_friend_acceptance(request, requester)
        salmon request, :to => requester
        request.destroy unless request.callback_url.include? url
      end 
      
      def accept_and_respond(friend_request_id, group_id)
        requester = Request.find_by_id(friend_request_id).person
        reversed_request = accept_friend_request(friend_request_id, group_id)
        dispatch_friend_acceptance reversed_request, requester
      end

      def ignore_friend_request(friend_request_id)
        request = Request.find_by_id(friend_request_id)
        person  = request.person

        person.user_refs -= 1

        self.pending_requests.delete(request)
        self.save

        (person.user_refs > 0 || person.owner.nil? == false) ?  person.save : person.destroy
        request.destroy
      end

      def receive_friend_request(friend_request)
        Rails.logger.info("receiving friend request #{friend_request.to_json}")
          
        if request_from_me?(friend_request)
          group = self.group_by_id(friend_request.group_id)
          activate_friend(friend_request.person, group)

          Rails.logger.info("#{self.real_name}'s friend request has been accepted")

          friend_request.destroy
        else
          friend_request.person.reload
          friend_request.person.user_refs += 1
          friend_request.person.save
          self.pending_requests << friend_request
          self.save
          Rails.logger.info("#{self.real_name} has received a friend request")
          friend_request.save
        end
      end

      def unfriend(bad_friend)
        Rails.logger.info("#{self.real_name} is unfriending #{bad_friend.inspect}")
        retraction = Retraction.for(self)
        salmon( retraction, :to => bad_friend)
        remove_friend(bad_friend)
      end
      
      def remove_friend(bad_friend)
        raise "Friend not deleted" unless self.friend_ids.delete( bad_friend.id )
        groups.each{|g| g.person_ids.delete( bad_friend.id )}
        self.save

        self.raw_visible_posts.find_all_by_person_id( bad_friend.id ).each{|post|
          self.visible_post_ids.delete( post.id )
          post.user_refs -= 1
          (post.user_refs > 0 || post.person.owner.nil? == false) ?  post.save : post.destroy
        }
        self.save

        bad_friend.user_refs -= 1
        (bad_friend.user_refs > 0 || bad_friend.owner.nil? == false) ?  bad_friend.save : bad_friend.destroy
      end

      def unfriended_by(bad_friend)
        Rails.logger.info("#{self.real_name} is being unfriended by #{bad_friend.inspect}")
        remove_friend bad_friend
      end

      def activate_friend(person, group)
        person.user_refs += 1
        group.people << person
        friends << person
        save
        person.save
        group.save
      end

      def request_from_me?(request)
        pending_requests.detect{|req| (req.callback_url == person.receive_url) && (req.destination_url == person.receive_url)}
      end
    end
  end
end
