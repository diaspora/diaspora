# frozen_string_literal: true

class ContactPresenter < BasePresenter
  def base_hash
    { id: id,
      person_id: person_id
    }
  end

  def full_hash
    base_hash.merge({
      aspect_memberships: aspect_memberships.map{ |membership| AspectMembershipPresenter.new(membership).base_hash }
    })
  end

  def full_hash_with_person
    full_hash.merge(person: person_without_contact)
  end

  private

  def person_without_contact
    PersonPresenter.new(person, current_user).as_json.except!(:contact)
  end
end
