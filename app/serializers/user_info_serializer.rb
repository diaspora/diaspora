# frozen_string_literal: true

class UserInfoSerializer < ActiveModel::Serializer
  attributes :sub, :name, :nickname, :profile, :picture

  def sub
    auth = serialization_options[:authorization]
    Api::OpenidConnect::SubjectIdentifierCreator.create(auth)
  end

  def name
    (object.first_name || "") + (object.last_name || "")
  end

  def nickname
    object.name
  end

  def profile
    api_v1_user_url
  end

  def picture
    object.image_url(fallback_to_default: false)
  end
end
