#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion
  attr_accessor :person, :user

  def initialize(diaspora_id)
    self.person = Person.where(:diaspora_handle => diaspora_id).first
    self.user = self.person.owner
  end

  def perform!
    delete_standard_associations
    disassociate_invitations
    delete_mentions
    delete_contacts_of_me
    disconnect_contacts
    delete_posts
    tombstone_person_and_profile
  end

  #user deletions
  def normal_ar_user_associates_to_delete
    [:tag_followings, :authorizations, :invitations_to_me, :services, :aspects, :user_preferences, :notifications] 
  end

  def special_ar_user_associations
    [:invitations_from_me, :person, :contacts]
  end

  def ignored_ar_user_associations
    [:followed_tags, :invited_by, :contact_people, :applications, :aspect_memberships]
  end
  
  def delete_standard_associations
    normal_ar_user_associates_to_delete.each do |asso|
      user.send(asso).delete_all
    end
  end

  def disassociate_invitations
    user.invitations_from_me.each do |inv|
      inv.convert_to_admin!
    end
  end

  def disconnect_contacts
    user.contacts.delete_all
  end


  #person deletion
# def delete_posts
# end

# def delete_photos
# end

# def comments
# end
  #
  def remove_share_visibilities
    #my_contacts = user.contacts.map{|x| x.id}
    #others_contacts = person.contacts{|x| x.id}
    #ShareVisibility.where(:contact_id => my_contacts + others_contacts)
  end

# def delete_notification_actors
# end

  def delete_posts
    self.person.posts.delete_all
  end

  def delete_photos
    self.person.photos.delete_all
  end

  def delete_mentions
    self.person.mentions.delete_all
  end

  def tombstone_person_and_profile
    self.person.close_account!
  end

  def delete_contacts_of_me
    Contact.all_contacts_of_person(self.person).delete_all
  end
end
