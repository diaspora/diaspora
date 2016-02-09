module Api
  module V0
    class BaseController < JSONAPI::ResourceController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      rescue_from Rack::OAuth2::Server::Resource::Bearer::Unauthorized do
        render json: {errors: {title:       "Unauthorized",
                               description: "Please pass in a valid access token",
                               status:      "401"}}
      end

      rescue_from Rack::OAuth2::Server::Resource::Bearer::Forbidden do
        render json: {errors: {title:       "Forbidden",
                               description: "This access token does not have the required scope",
                               status:      "403"}}
      end

      protected

      def context
        {current_user: current_user, params: params}
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
