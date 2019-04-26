# frozen_string_literal: true

class AccountMigration < ApplicationRecord
  include Diaspora::Federated::Base

  belongs_to :old_person, class_name: "Person"
  belongs_to :new_person, class_name: "Person"

  validates :old_person, uniqueness: true
  validates :new_person, uniqueness: true

  after_create :lock_old_user!

  attr_accessor :old_private_key
  attr_writer :old_person_diaspora_id

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
    validate_sender if locally_initiated?
    tombstone_old_user_and_update_all_references if old_person
    dispatch if locally_initiated?
    dispatch_contacts if remotely_initiated?
    update(completed_at: Time.zone.now)
  end

  def performed?
    !completed_at.nil?
  end

  # We assume that migration message subscribers are people that are subscribed to a new user profile updates.
  # Since during the migration we update contact references, this includes all the contacts of the old person.
  # In case when a user migrated to our pod from a remote one, we include remote person to subscribers so that
  # the new pod is informed about the migration as well.
  def subscribers
    new_user.profile.subscribers.remote.to_a.tap do |subscribers|
      subscribers.push(old_person) if old_person&.remote?
    end
  end

  # This method finds the newest user person profile in the migration chain.
  # If person migrated multiple times then #new_person may point to a closed account.
  # In this case in order to find open account we have to delegate new_person call to the next account_migration
  # instance in the chain.
  def newest_person
    return new_person if new_person.account_migration.nil?

    new_person.account_migration.newest_person
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
    old_person&.owner
  end

  def new_user
    new_person.owner
  end

  def newest_user
    newest_person.owner
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

  def tombstone_old_user_and_update_all_references
    ActiveRecord::Base.transaction do
      account_deleter.tombstone_person_and_profile
      account_deleter.close_user if user_left_our_pod?
      account_deleter.tombstone_user if user_changed_id_locally?

      update_all_references
    end
  end

  # We need to resend contacts of users of our pod for the remote new person so that the remote pod received this
  # contact information from the authoritative source.
  def dispatch_contacts
    newest_person.contacts.sharing.each do |contact|
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

  def old_person_diaspora_id
    old_person&.diaspora_handle || @old_person_diaspora_id
  end

  def ephemeral_sender
    if old_private_key.nil? || old_person_diaspora_id.nil?
      raise "can't build sender without old private key and diaspora ID defined"
    end

    EphemeralUser.new(old_person_diaspora_id, old_private_key)
  end

  def validate_sender
    sender # sender method raises exception when sender can't be instantiated
  end

  def update_all_references
    update_person_references
    update_user_references if user_changed_id_locally?
  end

  def person_references
    references = Person.reflections.reject {|key, _|
      %w[profile owner notifications pod account_migration].include?(key)
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

  def eliminate_person_duplicates
    duplicate_person_contacts.destroy_all
    duplicate_person_likes.destroy_all
    duplicate_person_participations.destroy_all
    duplicate_person_poll_participations.destroy_all
  end

  def duplicate_person_contacts
    Contact
      .joins("INNER JOIN contacts as c2 ON (contacts.user_id = c2.user_id AND contacts.person_id=#{old_person.id} AND"\
        " c2.person_id=#{newest_person.id})")
  end

  def duplicate_person_likes
    Like
      .joins("INNER JOIN likes as l2 ON (likes.target_id = l2.target_id "\
        "AND likes.target_type = l2.target_type "\
        "AND likes.author_id=#{old_person.id} AND"\
        " l2.author_id=#{newest_person.id})")
  end

  def duplicate_person_participations
    Participation
      .joins("INNER JOIN participations as p2 ON (participations.target_id = p2.target_id "\
        "AND participations.target_type = p2.target_type "\
        "AND participations.author_id=#{old_person.id} AND"\
        " p2.author_id=#{newest_person.id})")
  end

  def duplicate_person_poll_participations
    PollParticipation
      .joins("INNER JOIN poll_participations as p2 ON (poll_participations.poll_id = p2.poll_id "\
        "AND poll_participations.author_id=#{old_person.id} AND"\
        " p2.author_id=#{newest_person.id})")
  end

  def eliminate_user_duplicates
    Aspect
      .joins("INNER JOIN aspects as a2 ON (aspects.name = a2.name AND aspects.user_id=#{old_user.id}
        AND a2.user_id=#{newest_user.id})")
      .destroy_all
    Contact
      .joins("INNER JOIN contacts as c2 ON (contacts.person_id = c2.person_id AND contacts.user_id=#{old_user.id} AND"\
        " c2.user_id=#{newest_user.id})")
      .destroy_all
    TagFollowing
      .joins("INNER JOIN tag_followings as t2 ON (tag_followings.tag_id = t2.tag_id AND"\
        " tag_followings.user_id=#{old_user.id} AND t2.user_id=#{newest_user.id})")
      .destroy_all
  end

  def update_person_references
    logger.debug "Updating references from person id=#{old_person.id} to person id=#{newest_person.id}"
    eliminate_person_duplicates
    update_references(person_references, old_person, newest_person.id)
  end

  def update_user_references
    logger.debug "Updating references from user id=#{old_user.id} to user id=#{newest_user.id}"
    eliminate_user_duplicates
    update_references(user_references, old_user, newest_user.id)
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
