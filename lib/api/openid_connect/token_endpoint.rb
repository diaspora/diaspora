module Api
  module OpenidConnect
    class TokenEndpoint
      attr_accessor :app
      delegate :call, to: :app

      def initialize
        @app = Rack::OAuth2::Server::Token.new do |req, res|
          o_auth_app = retrieve_client(req)
          if app_valid?(o_auth_app, req)
            handle_flows(o_auth_app, req, res)
          else
            req.invalid_client!
          end
        end
      end

      def handle_flows(o_auth_app, req, res)
        case req.grant_type
        when :refresh_token
          handle_refresh_flow(req, res)
        when :authorization_code
          auth = Api::OpenidConnect::Authorization.with_redirect_uri(req.redirect_uri).use_code(req.code)
          req.invalid_grant! if auth.blank?
          res.access_token = auth.create_access_token
          if auth.accessible?(Api::OpenidConnect::Scope.find_by!(name: "openid"))
            id_token = auth.create_id_token
            res.id_token = id_token.to_jwt(access_token: res.access_token)
          end
        else
          req.unsupported_grant_type!
        end
      end

      def build_auth_and_access_token(auth, req, res)
        scope_list = req.scope.map { |scope_name|
          OpenidConnect::Scope.find_by(name: scope_name).tap do |scope|
            req.invalid_scope! "Unknown scope: #{scope}" unless scope
          end
        } # TODO: Check client scope permissions
        auth.scopes << scope_list
        res.access_token = auth.create_access_token
      end

      def handle_refresh_flow(req, res)
        # Handle as if scope request was omitted even if provided.
        # See https://tools.ietf.org/html/rfc6749#section-6 for handling
        auth = Api::OpenidConnect::Authorization.find_by_refresh_token req.client_id, req.refresh_token
        if auth
          res.access_token = auth.create_access_token
        else
          req.invalid_grant!
        end
      end

      def retrieve_client(req)
        Api::OpenidConnect::OAuthApplication.find_by client_id: req.client_id
      end

      def app_valid?(o_auth_app, req)
        o_auth_app.client_secret == req.client_secret
      end
    end
  end
end
