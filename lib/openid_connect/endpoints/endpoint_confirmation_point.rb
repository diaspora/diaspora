module OpenidConnect
  module Endpoints
    class EndpointConfirmationPoint < Endpoint
      def initialize(current_user, approved=false)
        super(current_user)
        @approved = approved
      end

      def build_attributes(req, res)
        super(req, res)
        # TODO: buildResponseType(req)
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

      def approved!(req, res)
        response_types = Array(req.response_type)
        if response_types.include?(:id_token)
          id_token = @user.id_tokens.create!(o_auth_application: o_auth_application, nonce: @nonce)
          options = %i(code access_token).map{|option| ["res.#{option}", res.respond_to?(option) ? res.option : nil]}.to_h
          res.id_token = id_token.to_jwt(options)
          # TODO: Add support for request object
        end
        res.approve!
      end
    end
  end
end
