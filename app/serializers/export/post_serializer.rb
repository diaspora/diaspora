module Export
  class PostSerializer < ActiveModel::Serializer
    attributes :guid,
               :text,
               :public,
               :diaspora_handle,
               :type,
               :likes_count,
               :comments_count,
               :reshares_count,
               :created_at
  end
end
