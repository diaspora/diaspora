module OpenidConnect
  module Authentication

    def self.included(klass)
      klass.send :include, Authentication::Helper
    end

    module Helper
      def current_token
        @current_token
      end
    end

    def require_access_token
      @current_token = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      unless @current_token
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new("Unauthorized user")
      end
      # TODO: This block is useless until we actually start checking for scopes
      unless @current_token.try(:accessible?, required_scopes)
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope)
      end
    end

    # TODO: Scopes should be implemented here
    def required_scopes
      nil
    end
  end
end
