#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion

  # Things that are not removed from the database:
  # - Comments
  # - Likes
  # - Messages
  # - NotificationActors
  #
  # Given that the User in question will be tombstoned, all of the
  # above will come from an anonomized account (via the UI).
  # The deleted user will appear as "Deleted Account" in
  # the interface.

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
    remove_share_visibilities
    remove_conversation_visibilities
    disconnect_contacts
    delete_photos
    delete_posts
    tombstone_person_and_profile
    tombstone_user
  end

  #user deletions
  def normal_ar_user_associates_to_delete
    [:tag_followings, :authorizations, :invitations_to_me, :services, :aspects, :user_preferences, :notifications, :blocks]
  end

  def special_ar_user_associations
    [:invitations_from_me, :person, :contacts]
  end

  def ignored_ar_user_associations
    [:followed_tags, :invited_by, :contact_people, :applications, :aspect_memberships]
  end

  def delete_standard_associations
    normal_ar_user_associates_to_delete.each do |asso|
      user.send(asso).destroy_all
    end
  end

  def disassociate_invitations
    user.invitations_from_me.each do |inv|
      inv.convert_to_admin!
    end
  end

  def disconnect_contacts
    user.contacts.destroy_all
  end

  def remove_share_visibilities
    ShareVisibility.for_a_users_contacts(user).destroy_all
    ShareVisibility.for_contacts_of_a_person(person).destroy_all
  end

  def remove_conversation_visibilities
    ConversationVisibility.where(:person_id => person.id).destroy_all
  end

  def delete_posts
    self.person.posts.destroy_all
  end

  def delete_photos
    self.person.photos.destroy_all
  end

  def delete_mentions
    self.person.mentions.destroy_all
  end

  def tombstone_person_and_profile
    self.person.close_account!
  end

  def tombstone_user
    self.user.close_account!
  end

  def delete_contacts_of_me
    Contact.all_contacts_of_person(self.person).destroy_all
  end
end
