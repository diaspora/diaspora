module Api
  module OpenidConnect
    module AuthorizationPoint
      class Endpoint
        attr_accessor :app, :user, :o_auth_application, :redirect_uri, :response_type,
                      :scopes, :request_uri, :request_object, :nonce
        delegate :call, to: :app

        def initialize(user)
          @user = user
          @app = Rack::OAuth2::Server::Authorize.new do |req, res|
            build_from_request_object(req)
            build_attributes(req, res)
            if OAuthApplication.available_response_types.include? Array(req.response_type).join(" ")
              handle_response_type(req, res)
            else
              req.unsupported_response_type!
            end
          end
        end

        def build_attributes(req, res)
          build_client(req)
          build_redirect_uri(req, res)
          verify_nonce(req, res)
          build_scopes(req)
        end

        def handle_response_type(_req, _res)
          raise NotImplementedError # Implemented by subclass
        end

        private

        def build_client(req)
          @o_auth_application = OAuthApplication.find_by_client_id(req.client_id) || req.bad_request!
        end

        def build_redirect_uri(req, res)
          res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@o_auth_application.redirect_uris)
        end

        def verify_nonce(req, res)
          req.invalid_request! "nonce required" if res.protocol_params_location == :fragment && req.nonce.blank?
        end

        def build_scopes(req)
          replace_profile_scope_with_specific_claims(req)
          @scopes = req.scope.map {|scope|
            scope.tap do |scope_name|
              req.invalid_scope! "Unknown scope: #{scope_name}" unless auth_scopes.include? scope_name
            end
          }
        end

        def auth_scopes
          Api::OpenidConnect::Authorization::SCOPES
        end
      end
    end
  end
end
