class OAuth2::Provider::Models::ActiveRecord::Client  
  def self.find_or_create_from_manifest!(manifest, pub_key)
    find_by_name(manifest['name']) || self.create!(
      :name => manifest["name"],
      :permissions_overview => manifest["permissions_overview"],
      :description => manifest["description"],
      :application_base_url => manifest["application_base_url"],
      :icon_url => manifest["icon_url"],
      :public_key => pub_key.export
    )
  end
end
