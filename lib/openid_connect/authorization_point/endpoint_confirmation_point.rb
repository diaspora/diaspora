module OpenidConnect
  module AuthorizationPoint
    class EndpointConfirmationPoint < Endpoint
      def initialize(current_user, approved=false)
        super(current_user)
        @approved = approved
      end

      def handle_response_type(req, res)
        handle_approval(@approved, req, res)
      end

      def handle_approval(approved, req, res)
        if approved
          approved!(req, res)
        else
          req.access_denied!
        end
      end

      # TODO: Add support for request object and auth code
      def approved!(req, res)
        auth = OpenidConnect::Authorization.find_or_create_by(o_auth_application: @o_auth_application, user: @user)
        auth.scopes << @scopes
        response_types = Array(req.response_type)
        if response_types.include?(:token)
          res.access_token = auth.create_access_token
        end
        if response_types.include?(:id_token)
          id_token = auth.create_id_token(req.nonce)
          access_token_value = res.respond_to?(:access_token) ? res.access_token : nil
          res.id_token = id_token.to_jwt(code: nil, access_token: access_token_value)
        end
        res.approve!
      end
    end
  end
end
