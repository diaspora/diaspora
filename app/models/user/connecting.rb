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
    register_share_visibilities(contact)
    contact
  end

  # This puts the last 100 public posts by the passed in contact into the user's stream.
  # @param [Contact] contact
  # @return [void]
  def register_share_visibilities(contact)
    #should have select here, but proven hard to test
    posts = Post.where(:author_id => contact.person_id, :public => true).limit(100)
    p = posts.map do |post|
      ShareVisibility.new(:contact_id => contact.id, :shareable_id => post.id, :shareable_type => 'Post')
    end
    ShareVisibility.import(p) unless posts.empty?
    nil
  end

  def remove_contact(contact, opts={:force => false, :retracted => false})
    posts = contact.posts.all

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
    Rails.logger.info("event=disconnect user=#{diaspora_handle} target=#{person.diaspora_handle}")
    retraction = Retraction.for(self)
    retraction.subscribers = [person]#HAX
    Postzord::Dispatcher.build(self, retraction).post

    AspectMembership.where(:contact_id => bad_contact.id).delete_all
    remove_contact(bad_contact, opts)
  end

  def disconnected_by(person)
    Rails.logger.info("event=disconnected_by user=#{diaspora_handle} target=#{person.diaspora_handle}")
    if contact = self.contact_for(person)
      remove_contact(contact, :retracted => true)
    end
  end
end
