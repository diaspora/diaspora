class UserSerializer < ActiveModel::Serializer
  attributes :name, :email, :language, :username
end
