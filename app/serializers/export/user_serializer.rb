module Export
  class UserSerializer < ActiveModel::Serializer
    attributes :name,
               :email,
               :language,
               :username,
               :disable_mail,
               :show_community_spotlight_in_stream,
               :auto_follow_back,
               :auto_follow_back_aspect,
               :strip_exif
    has_one    :profile,  serializer:      Export::ProfileSerializer
    has_many   :aspects,  each_serializer: Export::AspectSerializer
    has_many   :contacts, each_serializer: Export::ContactSerializer
    has_many   :posts,    each_serializer: Export::PostSerializer
    has_many   :comments, each_serializer: Export::CommentSerializer

    def comments
      object.person.comments
    end

  end
end
