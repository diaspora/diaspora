# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeleter

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

  def initialize(person)
    self.person = person
    self.user = person.owner
  end

  def perform!
    ActiveRecord::Base.transaction do
      #person
      delete_standard_person_associations
      remove_conversation_visibilities
      delete_contacts_of_me
      tombstone_person_and_profile

      close_user if user

      mark_account_deletion_complete
    end
  end

  # user deletion methods
  def close_user
    remove_share_visibilities_on_contacts_posts
    disconnect_contacts
    delete_standard_user_associations
    tombstone_user
  end

  #user deletions
  def normal_ar_user_associates_to_delete
    %i[tag_followings services aspects user_preferences
       notifications blocks authorizations o_auth_applications pairwise_pseudonymous_identifiers]
  end

  def special_ar_user_associations
    %i[person profile contacts auto_follow_back_aspect]
  end

  def ignored_ar_user_associations
    %i[followed_tags invited_by invited_users contact_people aspect_memberships
       ignored_people share_visibilities conversation_visibilities conversations reports]
  end

  def delete_standard_user_associations
    normal_ar_user_associates_to_delete.each do |asso|
      self.user.send(asso).each{|model| model.destroy }
    end
  end

  def delete_standard_person_associations
    normal_ar_person_associates_to_delete.each do |asso|
      self.person.send(asso).destroy_all
    end
  end

  def disconnect_contacts
    user.contacts.destroy_all
  end

  # Currently this would get deleted due to the db foreign key constrainsts,
  # but we'll keep this method here for completeness
  def remove_share_visibilities_on_contacts_posts
    ShareVisibility.for_a_user(user).destroy_all
  end

  def remove_conversation_visibilities
    ConversationVisibility.where(:person_id => person.id).destroy_all
  end

  def tombstone_person_and_profile
    self.person.lock_access!
    self.person.clear_profile!
  end

  def tombstone_user
    self.user.clear_account!
  end

  def delete_contacts_of_me
    Contact.all_contacts_of_person(self.person).destroy_all
  end

  def normal_ar_person_associates_to_delete
    %i[posts photos mentions participations roles blocks]
  end

  def ignored_or_special_ar_person_associations
    %i[comments likes poll_participations contacts notification_actors notifications owner profile
       conversation_visibilities pod conversations messages]
  end

  def mark_account_deletion_complete
    AccountDeletion.find_by(person: person)&.update_attributes(completed_at: Time.now.utc)
  end
end
