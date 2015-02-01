module Export
  class PostSerializer < ActiveModel::Serializer
    attributes :text,
               :public,
               :diaspora_handle,
               :type,
               :image_url,
               :image_height,
               :image_width,
               :likes_count,
               :comments_count,
               :reshares_count,
               :created_at
  end
end
