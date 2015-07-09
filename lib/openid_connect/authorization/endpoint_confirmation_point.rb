module OpenidConnect
  module Authorization
    class EndpointConfirmationPoint < Endpoint
      def initialize(current_user, approved = false)
        super(current_user)
        @approved = approved
      end

      def buildAttributes(req, res)
        super(req, res)
        # TODO: buildResponseType(req)
      end

      def handleResponseType(req, res)
        handleApproval(@approved, req, res)
      end

      def handleApproval(approved, req, res)
        if approved
          approved!(req, res)
        else
          req.access_denied!
        end
      end

      def approved!(req, res)
        response_types = Array(req.response_type)
        if response_types.include?(:id_token)
          res.id_token = SecureRandom.hex(16) # TODO: Replace with real ID token
        end
        res.approve!
      end
    end
  end
end
