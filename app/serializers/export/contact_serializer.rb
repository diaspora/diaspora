# frozen_string_literal: true

module Export
  class ContactSerializer < ActiveModel::Serializer
    attributes :sharing,
               :receiving,
               :following,
               :followed,
               :person_guid,
               :person_name,
               :account_id,
               :public_key

    has_many :contact_groups_membership

    def following
      object.sharing
    end

    def followed
      object.receiving
    end

    def account_id
      object.person_diaspora_handle
    end

    def contact_groups_membership
      object.aspects.map(&:name)
    end

    def public_key
      object.person.serialized_public_key
    end
  end
end
