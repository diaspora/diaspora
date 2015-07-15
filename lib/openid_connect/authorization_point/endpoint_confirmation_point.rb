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

      def approved!(req, res)
        auth = OpenidConnect::Authorization.find_or_create(req.client_id, @user)
        response_types = Array(req.response_type)
        if response_types.include?(:id_token)
          id_token = auth.id_tokens.create!(nonce: req.nonce)
          options = %i(code access_token).map{|option| ["res.#{option}", res.respond_to?(option) ? res.option : nil]}.to_h
          res.id_token = id_token.to_jwt(options)
          # TODO: Add support for request object
        end
        res.approve!
      end
    end
  end
end
