module Export
  class ProfileSerializer < ActiveModel::Serializer
    attributes :first_name,
               :last_name,
               :gender,
               :bio,
               :birthday,
               :location,
               :image_url,
               :diaspora_handle,
               :searchable,
               :nsfw
  end
end
