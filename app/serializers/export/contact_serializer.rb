module Export
  class ContactSerializer < ActiveModel::Serializer
    attributes :sharing,
               :receiving,
               :person_guid,
               :person_name,
               :person_first_name,
               :person_diaspora_handle

    has_many :aspects, each_serializer: Export::AspectSerializer
  end
end
