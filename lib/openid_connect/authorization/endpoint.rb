module OpenidConnect
  module Authorization
    class Endpoint
      attr_accessor :app, :user, :client, :redirect_uri, :response_type, :scopes, :_request_, :request_uri, :request_object
      delegate :call, to: :app

      def initialize(current_user)
        @user = current_user
        @app = Rack::OAuth2::Server::Authorize.new do |req, res|
          buildClient(req)
          buildRedirectURI(req, res)
          verifyNonce(req, res)
          buildScopes(req)
          buildRequestObject(req)
          if OAuthApplication.available_response_types.include? Array(req.response_type).collect(&:to_s).join(' ')
            handleResponseType(req, res)
          else
            req.unsupported_response_type!
          end
        end
      end
      def buildClient(req)
        @client = OAuthApplication.find_by_client_id(req.client_id) || req.bad_request!
      end
      def buildRedirectURI(req, res)
        res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)
      end
      def verifyNonce(req, res)
        if res.protocol_params_location == :fragment && req.nonce.blank?
          req.invalid_request! 'nonce required'
        end
      end
      def buildScopes(req)
        @scopes = req.scope.inject([]) do |_scopes_, scope|
          _scopes_ << Scope.find_by_name(scope) or req.invalid_scope! "Unknown scope: #{scope}"
        end
      end
      def buildRequestObject(req)
        @request_object = if (@_request_ = req.request).present?
                            OpenIDConnect::RequestObject.decode req.request, nil # @client.secret
                          elsif (@request_uri = req.request_uri).present?
                            OpenIDConnect::RequestObject.fetch req.request_uri, nil # @client.secret
                          end
      end
      def handleResponseType(req, res)
        # Implemented by subclass
      end
    end
  end
end
