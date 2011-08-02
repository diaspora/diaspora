module OAuth2::Provider::Models::Authorization
  extend ActiveSupport::Concern

  included do
    include OAuth2::Provider::Models::TokenExpiry
    self.default_token_lifespan = nil

    validates_presence_of :client
  end

  def has_scope?(s)
    scope && scope.split(" ").include?(s)
  end

  def revoke
    authorization_codes.destroy_all
    access_tokens.destroy_all
    destroy
  end

  def resource_owner=(ro)
    self.resource_owner_id = ro && ro.id
    self.resource_owner_type = ro && ro.class.name
  end

  def resource_owner
    resource_owner_id && resource_owner_class.find(resource_owner_id)
  end

  def resource_owner_class
    resource_owner_type.constantize
  end

  module ClassMethods
    def all_for(ro)
      return [] unless ro
      self.where(:resource_owner_id => ro.id, :resource_owner_type => ro.class.name).all
    end
  end
end