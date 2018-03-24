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
    # close person
    delete_standard_person_associations
    delete_contacts_of_me
    tombstone_person_and_profile

    close_user if user

    mark_account_deletion_complete
  end

  # user deletion methods
  def close_user
    remove_share_visibilities_on_contacts_posts
    disconnect_contacts
    delete_standard_user_associations
    tombstone_user
  end

  # user deletions
  def normal_ar_user_associates_to_delete
    %i[tag_followings services aspects user_preferences
       notifications blocks authorizations o_auth_applications pairwise_pseudonymous_identifiers]
  end

  def delete_standard_user_associations
    normal_ar_user_associates_to_delete.each do |asso|
      user.send(asso).ids.each_slice(20) do |ids|
        User.reflect_on_association(asso).class_name.constantize.where(id: ids).destroy_all
      end
    end
  end

  def normal_ar_person_associates_to_delete
    %i[posts photos mentions participations roles blocks conversation_visibilities]
  end

  def delete_standard_person_associations
    normal_ar_person_associates_to_delete.each do |asso|
      person.send(asso).ids.each_slice(20) do |ids|
        Person.reflect_on_association(asso).class_name.constantize.where(id: ids).destroy_all
      end
    end
  end

  def disconnect_contacts
    user.contacts.destroy_all
  end

  # Currently this would get deleted due to the db foreign key constrainsts,
  # but we'll keep this method here for completeness
  def remove_share_visibilities_on_contacts_posts
    ShareVisibility.for_a_user(user).find_each(batch_size: 20, &:destroy)
  end

  def tombstone_person_and_profile
    person.lock_access!
    person.clear_profile!
  end

  def tombstone_user
    user.clear_account!
  end

  def delete_contacts_of_me
    Contact.all_contacts_of_person(person).find_each(batch_size: 20, &:destroy)
  end

  def mark_account_deletion_complete
    AccountDeletion.find_by(person: person)&.update_attributes(completed_at: Time.now.utc)
  end
end
