# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class User
  module Connecting
    # This will create a contact on the side of the sharer and the sharee.
    # @param [Person] person The person to start sharing with.
    # @param [Aspect] aspect The aspect to add them to.
    # @return [Contact] The newly made contact for the passed in person.
    def share_with(person, aspect)
      contact = contacts.find_or_initialize_by(person_id: person.id)
      return false unless contact.valid?

      needs_dispatch = !contact.receiving?
      contact.receiving = true
      contact.aspects << aspect
      contact.save

      if needs_dispatch
        Diaspora::Federation::Dispatcher.defer_dispatch(self, contact)
        deliver_profile_update(subscriber_ids: [person.id]) unless person.local?
      end

      Notifications::StartedSharing.where(recipient_id: id, target: person.id, unread: true)
                                   .update_all(unread: false)

      contact
    end

    def disconnect(contact)
      logger.info "event=disconnect user=#{diaspora_handle} target=#{contact.person.diaspora_handle}"

      if contact.person.local?
        contact.person.owner.disconnected_by(contact.user.person)
      else
        ContactRetraction.for(contact).defer_dispatch(self)
      end

      contact.aspect_memberships.delete_all

      disconnect_contact(contact, direction: :receiving, destroy: !contact.sharing)
    end

    def disconnected_by(person)
      logger.info "event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}"
      contact_for(person).try {|contact| disconnect_contact(contact, direction: :sharing, destroy: !contact.receiving) }
    end

    private

    def disconnect_contact(contact, direction:, destroy:)
      if destroy
        contact.destroy
      else
        contact.update_attributes(direction => false)
      end
    end
  end
end
