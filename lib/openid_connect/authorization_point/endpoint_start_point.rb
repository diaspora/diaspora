module OpenidConnect
  module AuthorizationPoint
    class EndpointStartPoint < Endpoint
      def handle_response_type(req, _res)
        @response_type = req.response_type
      end

      # TODO: buildRequestObject(req)
    end
  end
end
