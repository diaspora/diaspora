class OAuth2::Provider::Models::ActiveRecord::Client 
  def self.create_or_reset_from_manifest! manifest
    if obj = find_by_name(manifest['name'])
      obj.oauth_identifier = OAuth2::Provider::Random.base62(16)
      obj.oauth_secret = OAuth2::Provider::Random.base62(32)
      obj.save!
      obj
    else
      create!(manifest)
    end
  end
end
