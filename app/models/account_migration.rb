# frozen_string_literal: true

class AccountMigration < ApplicationRecord
  include Diaspora::Federated::Base

  belongs_to :old_person, class_name: "Person"
  belongs_to :new_person, class_name: "Person"

  validates :old_person, uniqueness: true
  validates :new_person, uniqueness: true

  after_create :lock_old_user!

  attr_accessor :old_private_key

  def receive(*)
    perform!
  end

  def public?
    true
  end

  def sender
    @sender ||= old_user || ephemeral_sender
  end

  # executes a migration plan according to this AccountMigration object
  def perform!
    raise "already performed" if performed?

    ActiveRecord::Base.transaction do
      account_deleter.tombstone_person_and_profile
      account_deleter.close_user if user_left_our_pod?
      account_deleter.tombstone_user if user_changed_id_locally?

      update_all_references
    end

    dispatch if locally_initiated?
    dispatch_contacts if remotely_initiated?
  end

  def performed?
    old_person.closed_account?
  end

  # We assume that migration message subscribers are people that are subscribed to a new user profile updates.
  # Since during the migration we update contact references, this includes all the contacts of the old person.
  # In case when a user migrated to our pod from a remote one, we include remote person to subscribers so that
  # the new pod is informed about the migration as well.
  def subscribers
    new_user.profile.subscribers.remote.to_a.tap do |subscribers|
      subscribers.push(old_person) if old_person.remote?
    end
  end

  private

  # Normally pod initiates migration locally when the new user is local. Then the pod creates AccountMigration object
  # itself. If new user is remote, then AccountMigration object is normally received via the federation and this is
  # remote initiation then.
  def remotely_initiated?
    new_person.remote?
  end

  def locally_initiated?
    !remotely_initiated?
  end

  def old_user
    old_person.owner
  end

  def new_user
    new_person.owner
  end

  def lock_old_user!
    old_user&.lock_access!
  end

  def user_left_our_pod?
    old_user && !new_user
  end

  def user_changed_id_locally?
    old_user && new_user
  end

  # We need to resend contacts of users of our pod for the remote new person so that the remote pod received this
  # contact information from the authoritative source.
  def dispatch_contacts
    new_person.contacts.sharing.each do |contact|
      Diaspora::Federation::Dispatcher.defer_dispatch(contact.user, contact)
    end
  end

  def dispatch
    Diaspora::Federation::Dispatcher.build(sender, self).dispatch
  end

  EphemeralUser = Struct.new(:diaspora_handle, :serialized_private_key) do
    def id
      diaspora_handle
    end

    def encryption_key
      OpenSSL::PKey::RSA.new(serialized_private_key)
    end
  end

  def ephemeral_sender
    raise "can't build sender without old private key defined" if old_private_key.nil?
    EphemeralUser.new(old_person.diaspora_handle, old_private_key)
  end

  def update_all_references
    update_person_references
    update_user_references if user_changed_id_locally?
  end

  def person_references
    references = Person.reflections.reject {|key, _|
      %w[profile owner notifications pod].include?(key)
    }

    references.map {|key, value|
      {value.foreign_key => key}
    }
  end

  def user_references
    references = User.reflections.reject {|key, _|
      %w[
        person profile auto_follow_back_aspect invited_by aspect_memberships contact_people followed_tags
        ignored_people conversation_visibilities pairwise_pseudonymous_identifiers conversations o_auth_applications
      ].include?(key)
    }

    references.map {|key, value|
      {value.foreign_key => key}
    }
  end

  def update_person_references
    logger.debug "Updating references from person id=#{old_person.id} to person id=#{new_person.id}"
    update_references(person_references, old_person, new_person.id)
  end

  def update_user_references
    logger.debug "Updating references from user id=#{old_user.id} to user id=#{new_user.id}"
    update_references(user_references, old_user, new_user.id)
  end

  def update_references(references, object, new_id)
    references.each do |pair|
      key_id = pair.flatten[0]
      association = pair.flatten[1]
      object.send(association).update_all(key_id => new_id)
    end
  end

  def account_deleter
    @account_deleter ||= AccountDeleter.new(old_person)
  end
end
