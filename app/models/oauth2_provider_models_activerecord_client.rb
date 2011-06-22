class OAuth2::Provider::Models::ActiveRecord::Client 
  def self.create_or_reset_from_manifest! manifest
    if obj = find_by_name(manifest['name'])
      obj.oauth_identifier = OAuth2::Provider::Random.base62(16)
      obj.oauth_secret = OAuth2::Provider::Random.base62(32)
      obj.save!
      obj
    else
      self.create!(
        :name => manifest["name"],
        :permissions_overview => manifest["permissions_overview"],
        :description => manifest["description"],
        :homepage_url => manifest["homepage_url"],
        :icon_url => manifest["icon_url"],
        :public_key => manifest["public_key"]
      )
    end
  end
end
