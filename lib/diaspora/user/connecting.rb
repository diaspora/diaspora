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
        if notification = Notification.first(:target_id=>request.id)
          notification.update_attributes(:unread=>false)
        end

        activate_contact(request.from, aspect)
        request.destroy
        request.reverse_for(self)
      end

      def dispatch_contact_acceptance(request, requester)
        push_to_people request, [requester]
        request.destroy unless request.from.owner
      end

      def accept_and_respond(contact_request_id, aspect_id)
        request          = Request.to(self.person).find!(contact_request_id)
        requester        = request.from
        reversed_request = accept_contact_request(request, aspect_by_id(aspect_id))
        dispatch_contact_acceptance reversed_request, requester
      end

      def ignore_contact_request(contact_request_id)
        request = Request.to(self.person).find!(contact_request_id)
        request.destroy
      end

      def receive_contact_request(contact_request)

        #response from a contact request you sent
        if original_contact = self.contact_for(contact_request.from)
          receive_request_acceptance(contact_request, original_contact)

        #this is a new contact request
        elsif contact_request.from != self.person
          if contact_request.save!
            Rails.logger.info("event=contact_request status=received_new_request from=#{contact_request.from.diaspora_handle} to=#{self.diaspora_handle}")
            self.mail(Jobs::MailRequestReceived, self.id, contact_request.from.id)
          end
        else
          Rails.logger.info "event=contact_request status=abort from=#{contact_request.from.diaspora_handle} to=#{self.diaspora_handle} reason=self-love"
          return nil
        end
        contact_request
      end

      def receive_request_acceptance(received_request, contact)
        contact.pending = false
        contact.save
        Rails.logger.info("event=contact_request status=received_acceptance from=#{received_request.from.diaspora_handle} to=#{self.diaspora_handle}")

        received_request.destroy
        self.save
        self.mail(Jobs::MailRequestAcceptance, self.id, received_request.from.id)
      end

      def disconnect(bad_contact)
        Rails.logger.info("event=disconnect user=#{diaspora_handle} target=#{bad_contact.diaspora_handle}")
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
        Rails.logger.info("event=disconnected_by user=#{diaspora_handle} target=#{bad_contact.diaspora_handle}")
        remove_contact bad_contact
      end

      def activate_contact(person, aspect)
        new_contact = Contact.create!(:user => self,
          :person => person,
          :aspects => [aspect],
          :pending => false)
        new_contact.aspects << aspect
        save!
        aspect.save!
      end
    end
  end
end
