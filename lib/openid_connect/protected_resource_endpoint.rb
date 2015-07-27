module OpenidConnect
  module ProtectedResourceEndpoint
    attr_reader :current_token

    def require_access_token(*required_scopes)
      @current_token = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      unless @current_token && @current_token.authorization
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new("Unauthorized user")
      end
      unless @current_token.authorization.try(:accessible?, required_scopes)
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope)
      end
    end
  end
end
