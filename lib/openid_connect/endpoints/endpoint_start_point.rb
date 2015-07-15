module OpenidConnect
  module Endpoints
    class EndpointStartPoint < Endpoint
      def handle_response_type(req, res)
        @response_type = req.response_type
      end

      def build_attributes(req, res)
        super(req, res)
        verify_nonce(req, res)
        build_scopes(req)
        # TODO: buildRequestObject(req)
      end

      def verify_nonce(req, res)
        if res.protocol_params_location == :fragment && req.nonce.blank?
          req.invalid_request! "nonce required"
        end
      end

      def build_scopes(req)
        @scopes = req.scope.map {|scope|
          OpenidConnect::Scope.where(name: scope).first.tap do |scope|
            req.invalid_scope! "Unknown scope: #{scope}" unless scope
          end
        }
      end
    end
  end
end
