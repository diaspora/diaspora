class OAuth2::Provider::Models::ActiveRecord::Authorization
  validates_presence_of :resource_owner_id, :resource_owner_type
  validates_uniqueness_of [:resource_owner_id, :resource_owner_type] , :scope => :client_id
end
