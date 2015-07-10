module OpenidConnect
  module Authorization
    class EndpointStartPoint < Endpoint
      def initialize(current_user)
        super(current_user)
      end
      def handleResponseType(req, res)
        @response_type = req.response_type
      end
      def buildAttributes(req, res)
        super(req, res)
        verifyNonce(req, res)
        buildScopes(req)
        # TODO: buildRequestObject(req)
      end
      def verifyNonce(req, res)
        if res.protocol_params_location == :fragment && req.nonce.blank?
          req.invalid_request! "nonce required"
        end
      end
      def buildScopes(req)
        @scopes = req.scope.inject([]) do |_scopes_, scope|
          _scopes_ << (Scope.find_by_name(scope) or req.invalid_scope! "Unknown scope: #{scope}")
        end
      end
    end
  end
end
