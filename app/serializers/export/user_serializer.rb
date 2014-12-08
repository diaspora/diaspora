module Export
  class UserSerializer < ActiveModel::Serializer
    attributes :name,
               :email,
               :language,
               :username,
               :disable_mail,
               :show_community_spotlight_in_stream,
               :auto_follow_back,
               :auto_follow_back_aspect
    has_one    :profile,  serializer:      Export::ProfileSerializer
    has_many   :aspects,  each_serializer: Export::AspectSerializer
    has_many   :contacts, each_serializer: Export::ContactSerializer

  end
end