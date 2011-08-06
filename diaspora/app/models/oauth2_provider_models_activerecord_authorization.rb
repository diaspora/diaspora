class OAuth2::Provider::Models::ActiveRecord::Authorization
  validates_presence_of :resource_owner_id, :resource_owner_type
  validates_uniqueness_of :client_id, :scope => :resource_owner_id
end
