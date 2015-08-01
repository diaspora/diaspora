class UserInfoSerializer < ActiveModel::Serializer
  attributes :sub, :nickname, :profile, :picture, :zoneinfo

  def sub
    auth = serialization_options[:authorization]
    if auth.o_auth_application.ppid?
      sector_identifier = auth.o_auth_application.sector_identifier_uri
      pairwise_pseudonymous_identifier =
        object.pairwise_pseudonymous_identifiers.find_or_create_by(sector_identifier: sector_identifier)
      pairwise_pseudonymous_identifier.guid
    else
      object.diaspora_handle
    end
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
