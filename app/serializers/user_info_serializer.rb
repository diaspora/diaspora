class UserInfoSerializer < ActiveModel::Serializer
  attributes :sub, :nickname, :profile, :picture

  def sub
    auth = serialization_options[:authorization]
    Api::OpenidConnect::SubjectIdentifierCreator.createSub(auth)
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
