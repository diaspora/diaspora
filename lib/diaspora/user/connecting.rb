#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Connecting
      def send_contact_request_to(desired_contact, aspect)
        request = Request.instantiate(:to => desired_contact, 
                                      :from => self.person,
                                      :into => aspect)
        if request.save!
          dispatch_request request
        end
        request
      end

      def dispatch_request(request)
        self.pending_requests << request
        self.save

        request.into.requests << request
        request.into.save
        push_to_people request, [request.to]
      end

      def accept_contact_request(request, aspect)
        pending_request_ids.delete(request.id.to_id)
        activate_contact(request.from, aspect)
        request.destroy
        request.reverse_for(self)
      end

      def dispatch_contact_acceptance(request, requester)
        push_to_people request, [requester]
        request.destroy unless request.from.owner
      end

      def accept_and_respond(contact_request_id, aspect_id)
        request          = pending_requests.find!(contact_request_id)
        requester        = request.from
        reversed_request = accept_contact_request(request, aspect_by_id(aspect_id))
        dispatch_contact_acceptance reversed_request, requester
      end

      def ignore_contact_request(contact_request_id)
        request = pending_requests.find!(contact_request_id)
        person  = request.from

        self.pending_request_ids.delete(request.id)
        self.save

        person.save
        request.destroy
      end

      def receive_contact_request(contact_request)
        Rails.logger.info("receiving contact request #{contact_request.to_json}")

        #response from a contact request you sent
        if original_request = original_request(contact_request)
          receive_request_acceptance(contact_request, original_request)

          #this is a new contact request
        elsif !request_from_me?(contact_request)
          self.pending_requests << contact_request
          self.save!
          Rails.logger.info("#{self.real_name} has received a contact request")
          contact_request.save
          Request.send_new_request(self, contact_request.from)
        else
          raise "#{self.real_name} is trying to receive a contact request from himself."
        end
        contact_request
      end

      def receive_request_acceptance(received_request, sent_request)
        destination_aspect = self.aspect_by_id(sent_request.into_id)
        activate_contact(received_request.from, destination_aspect)
        Rails.logger.info("#{self.real_name}'s contact request has been accepted")

        received_request.destroy
        pending_requests.delete(sent_request)
        sent_request.destroy
        self.save
        Request.send_request_accepted(self, received_request.from, destination_aspect)
      end

      def disconnect(bad_contact)
        Rails.logger.info("#{self.real_name} is disconnecting #{bad_contact.inspect}")
        retraction = Retraction.for(self)
        push_to_people retraction, [bad_contact]
        remove_contact(bad_contact)
      end

      def remove_contact(bad_contact)
        contact = contact_for(bad_contact)
        contact.aspects.each do |aspect|
          contact.aspects.delete(aspect)
          aspect.posts.each do |post|
            aspect.post_ids.delete(post.id) if post.person == bad_contact
          end
          aspect.save
        end

        self.raw_visible_posts.find_all_by_person_id(bad_contact.id).each do |post|
          self.visible_post_ids.delete(post.id)
          post.user_refs -= 1
          if (post.user_refs > 0) || post.person.owner.nil? == false
            post.save
          else
            post.destroy
          end
        end
        self.save
        raise "Contact not deleted" unless contact.destroy
        bad_contact.save
      end

      def disconnected_by(bad_contact)
        Rails.logger.info("#{self.real_name} is being disconnected by #{bad_contact.inspect}")
        remove_contact bad_contact
      end

      def activate_contact(person, aspect)
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
        pending_requests.select { |req| req.to == self.person }
      end
    end
  end
end
