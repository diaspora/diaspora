class UserInfoSerializer < ActiveModel::Serializer
  attributes :sub, :nickname, :profile, :picture, :zoneinfo

  def sub
    object.diaspora_handle # TODO: Change to proper sub
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

  def zoneinfo
    object.language
  end
end
