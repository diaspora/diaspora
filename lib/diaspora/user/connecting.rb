#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Connecting
      def send_contact_request_to(desired_contact, aspect)
        contact = Contact.new(:person => desired_contact,
                              :user => self,
                              :pending => true)
        contact.aspects << aspect

        if contact.save!
          request = contact.dispatch_request
          request
        else
          nil
        end
      end

      def accept_contact_request(request, aspect)
        activate_contact(request.sender, aspect)

        if notification = Notification.where(:target_id=>request.id).first
          notification.update_attributes(:unread=>false)
        end

        request.destroy
        request.reverse_for(self)
      end

      def dispatch_contact_acceptance(request, requester)
        Postzord::Dispatch.new(self, request).post

        request.destroy unless request.sender.owner
      end

      def accept_and_respond(contact_request_id, aspect_id)
        request          = Request.where(:recipient_id => self.person.id, :id => contact_request_id).first
        requester        = request.sender
        reversed_request = accept_contact_request(request, aspects.where(:id => aspect_id).first )
        dispatch_contact_acceptance reversed_request, requester
      end

      def ignore_contact_request(contact_request_id)
        request = Request.where(:recipient_id => self.person.id, :id => contact_request_id).first
        request.destroy
      end

      def receive_contact_request(contact_request)
        #response from a contact request you sent
        if original_contact = self.contact_for(contact_request.sender)
          receive_request_acceptance(contact_request, original_contact)
        #this is a new contact request
        elsif contact_request.sender != self.person
          if contact_request.save!
            Rails.logger.info("event=contact_request status=received_new_request from=#{contact_request.sender.diaspora_handle} to=#{self.diaspora_handle}")
          end
        else
          Rails.logger.info "event=contact_request status=abort from=#{contact_request.sender.diaspora_handle} to=#{self.diaspora_handle} reason=self-love"
          return nil
        end
        contact_request
      end

      def receive_request_acceptance(received_request, contact)
        contact.pending = false
        contact.save
        Rails.logger.info("event=contact_request status=received_acceptance from=#{received_request.sender.diaspora_handle} to=#{self.diaspora_handle}")

        received_request.destroy
        self.save
      end

      def disconnect(bad_contact)
        person = bad_contact.person
        Rails.logger.info("event=disconnect user=#{diaspora_handle} target=#{person.diaspora_handle}")
        retraction = Retraction.for(self)
        retraction.subscribers = [person]#HAX
        Postzord::Dispatch.new(self, retraction).post
        remove_contact(bad_contact)
      end

      def remove_contact(contact)
        bad_person_id = contact.person_id
        posts = raw_visible_posts.where(:author_id => bad_person_id).all
        visibilities = PostVisibility.joins(:post, :aspect).where(
          :posts => {:author_id => bad_person_id},
          :aspects => {:user_id => self.id}
        )
        visibility_ids = visibilities.map{|v| v.id}
        PostVisibility.where(:id => visibility_ids).delete_all
        posts.each do |post|
          if post.post_visibilities(true).count < 1
            post.destroy
          end
        end
        contact.destroy
      end

      def disconnected_by(person)
        Rails.logger.info("event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}")
        if contact = self.contact_for(person)
          remove_contact(contact)
        elsif request = Request.where(:recipient_id => self.person.id, :sender_id => person.id).first
          request.delete
        end
      end

      def activate_contact(person, aspect)
        new_contact = Contact.create!(:user => self,
          :person => person,
          :aspects => [aspect],
          :pending => false)
      end
    end
  end
end
