module Export
  class CommentSerializer < ActiveModel::Serializer
    attributes :text,
               :post_guid

    def post_guid
      object.post.guid
    end
  end
end
