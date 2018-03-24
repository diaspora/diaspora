# frozen_string_literal: true

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

        def replace_profile_scope_with_specific_claims(_req)
          # Empty
        end

        def build_from_request_object(_req)
          # Empty
        end

        private

        def approved!(req, res)
          auth = find_or_build_auth(req)
          handle_approved_response_type(auth, req, res)
          res.approve!
        end

        def find_or_build_auth(req)
          OpenidConnect::Authorization.find_or_create_by!(
            o_auth_application: @o_auth_application, user: @user, redirect_uri: @redirect_uri).tap do |auth|
            auth.nonce = req.nonce
            auth.scopes = @scopes
            auth.save
          end
        end

        def handle_approved_response_type(auth, req, res)
          response_types = Array(req.response_type)
          handle_approved_auth_code(auth, res, response_types)
          handle_approved_access_token(auth, res, response_types)
          handle_approved_id_token(auth, res, response_types)
        end

        def handle_approved_auth_code(auth, res, response_types)
          return unless response_types.include?(:code)
          res.code = auth.create_code
        end

        def handle_approved_access_token(auth, res, response_types)
          return unless response_types.include?(:token)
          res.access_token = auth.create_access_token
        end

        def handle_approved_id_token(auth, res, response_types)
          return unless response_types.include?(:id_token)
          id_token = auth.create_id_token
          res.id_token = id_token.to_jwt(code: res.try(:code), access_token: res.try(:access_token))
        end
      end
    end
  end
end
