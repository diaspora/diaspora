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

      unless contact.receiving?
        # TODO: dispatch
        contact.receiving = true
      end

      contact.aspects << aspect
      contact.save

      Notifications::StartedSharing.where(recipient_id: id, target: person.id, unread: true)
                                   .update_all(unread: false)

      deliver_profile_update
      contact
    end

    def disconnect(contact, opts={force: false})
      logger.info "event=disconnect user=#{diaspora_handle} target=#{contact.person.diaspora_handle}"

      # TODO: send retraction

      contact.aspect_memberships.delete_all

      if !contact.sharing || opts[:force]
        contact.destroy
      else
        contact.update_attributes(receiving: false)
      end
    end

    def disconnected_by(person)
      logger.info "event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}"
      contact = contact_for(person)
      return unless contact

      if contact.receiving
        contact.update_attributes(sharing: false)
      else
        contact.destroy
      end
    end
  end
end
