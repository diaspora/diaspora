module Export
  class CommentSerializer < ActiveModel::Serializer
    attributes :guid,
               :text,
               :post_guid

    def post_guid
      object.post.guid
    end
  end
end
