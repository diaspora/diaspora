#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Connecting
      # This will create a contact on the side of the sharer and the sharee.
      # @param [Person] person The person to start sharing with.
      # @param [Aspect] aspect The aspect to add them to.
      # @return [Contact] The newly made contact for the passed in person.
      def share_with(person, aspect)
        contact = self.contacts.find_or_initialize_by_person_id(person.id)
        unless contact.receiving?
          contact.dispatch_request
          contact.receiving = true
        end

        contact.aspects << aspect
        contact.save

        if notification = Notification.where(:target_id => person.id).first
          notification.update_attributes(:unread=>false)
        end
        
        register_post_visibilities(contact)
        contact
      end

      def register_post_visibilities(contact)
        #should have select here, but proven hard to test
        posts = Post.where(:author_id => contact.person_id, :public => true).limit(100)
        p = posts.map do |post|
          PostVisibility.new(:contact_id => contact.id, :post_id => post.id)
        end
        PostVisibility.import(p) unless posts.empty?
        nil
      end

      def remove_contact(contact, opts={:force => false})
        posts = contact.posts.all

        if !contact.mutual? || opts[:force]
          contact.destroy
        else
          contact.update_attributes(:receiving => false)
        end

        posts.each do |p|
          if p.user_refs < 1
            p.destroy
          end
        end
      end

      def disconnect(bad_contact)
        person = bad_contact.person
        Rails.logger.info("event=disconnect user=#{diaspora_handle} target=#{person.diaspora_handle}")
        retraction = Retraction.for(self)
        retraction.subscribers = [person]#HAX
        Postzord::Dispatch.new(self, retraction).post

        AspectMembership.where(:contact_id => bad_contact.id).delete_all
        remove_contact(bad_contact)
      end

      def disconnected_by(person)
        Rails.logger.info("event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}")
        if contact = self.contact_for(person)
          remove_contact(contact)
        end
      end
    end
  end
end
