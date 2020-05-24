# frozen_string_literal: true

module Api
  module OpenidConnect
    module AuthorizationPoint
      class EndpointStartPoint < Endpoint
        def build_from_request_object(req)
          request_object = build_request_object(req)
          return unless request_object
          claims = request_object.raw_attributes.with_indifferent_access[:claims].try(:[], :userinfo).try(:keys)
          return unless claims
          req.update_param("scope", req.scope + claims)
        end

        def handle_response_type(req, _res)
          @response_type = req.response_type
        end

        private

        def build_request_object(req)
          if req.request_uri.present?
            OpenIDConnect::RequestObject.fetch req.request_uri
          elsif req.request.present?
            OpenIDConnect::RequestObject.decode req.request
          end
        end
      end
    end
  end
end
