#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module User::Connecting
  # This will create a contact on the side of the sharer and the sharee.
  # @param [Person] person The person to start sharing with.
  # @param [Aspect] aspect The aspect to add them to.
  # @return [Contact] The newly made contact for the passed in person.
  def share_with(person, aspect)
    contact = self.contacts.find_or_initialize_by(person_id: person.id)
    return false unless contact.valid?

    unless contact.receiving?
      contact.dispatch_request
      contact.receiving = true
    end

    contact.aspects << aspect
    contact.save

    if notification = Notification.where(:target_id => person.id).first
      notification.update_attributes(:unread=>false)
    end

    deliver_profile_update
    contact
  end

  def remove_contact(contact, opts={:force => false, :retracted => false})
    if !contact.mutual? || opts[:force]
      contact.destroy
    elsif opts[:retracted]
      contact.update_attributes(:sharing => false)
    else
      contact.update_attributes(:receiving => false)
    end
  end

  def disconnect(bad_contact, opts={})
    person = bad_contact.person
    logger.info "event=disconnect user=#{diaspora_handle} target=#{person.diaspora_handle}"
    retraction = Retraction.for(self)
    retraction.subscribers = [person]#HAX
    Postzord::Dispatcher.build(self, retraction).post

    AspectMembership.where(:contact_id => bad_contact.id).delete_all
    remove_contact(bad_contact, opts)
  end

  def disconnected_by(person)
    logger.info "event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}"
    if contact = self.contact_for(person)
      remove_contact(contact, :retracted => true)
    end
  end
end
