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
    File.join(AppConfig.environment.url, "people", object.guid).to_s
  end

  def picture
    File.join(AppConfig.environment.url, object.image_url).to_s
  end
end
