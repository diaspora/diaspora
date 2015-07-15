module OpenidConnect
  module Authorization
    class Endpoint
      attr_accessor :app, :user, :o_auth_application, :redirect_uri, :response_type,
                    :scopes, :_request_, :request_uri, :request_object, :nonce
      delegate :call, to: :app

      def initialize(current_user)
        @user = current_user
        @app = Rack::OAuth2::Server::Authorize.new do |req, res|
          build_attributes(req, res)
          if OAuthApplication.available_response_types.include? Array(req.response_type).map(&:to_s).join(" ")
            handle_response_type(req, res)
          else
            req.unsupported_response_type!
          end
        end
      end

      def build_attributes(req, res)
        build_client(req)
        build_redirect_uri(req, res)
      end

      def handle_response_type(req, res)
        # Implemented by subclass
      end

      private

      def build_client(req)
        @o_auth_application = OAuthApplication.find_by_client_id(req.client_id) || req.bad_request!
      end

      def build_redirect_uri(req, res)
        res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@o_auth_application.redirect_uris)
      end
    end
  end
end
