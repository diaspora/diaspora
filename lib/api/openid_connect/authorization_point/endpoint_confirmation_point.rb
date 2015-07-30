module Api
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

        # TODO: Add support for request object
        def approved!(req, res)
          auth = OpenidConnect::Authorization.find_or_create_by(
            o_auth_application: @o_auth_application, user: @user, redirect_uri: @redirect_uri)
          auth.scopes << @scopes
          handle_approved_response_type(auth, req, res)
          res.approve!
        end

        def handle_approved_response_type(auth, req, res)
          response_types = Array(req.response_type)
          handle_approved_auth_code(auth, res, response_types)
          handle_approved_access_token(auth, res, response_types)
          handle_approved_id_token(auth, req, res, response_types)
        end

        def handle_approved_auth_code(auth, res, response_types)
          return unless response_types.include?(:code)
          res.code = auth.create_code
        end

        def handle_approved_access_token(auth, res, response_types)
          return unless response_types.include?(:token)
          res.access_token = auth.create_access_token
        end

        def handle_approved_id_token(auth, req, res, response_types)
          return unless response_types.include?(:id_token)
          id_token = auth.create_id_token(req.nonce)
          auth_code_value = res.respond_to?(:code) ? res.code : nil
          access_token_value = res.respond_to?(:access_token) ? res.access_token : nil
          res.id_token = id_token.to_jwt(code: auth_code_value, access_token: access_token_value)
        end
      end
    end
  end
end
