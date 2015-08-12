module Api
  module OpenidConnect
    class UserInfoController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      before_action do
        require_access_token ["openid"]
      end

      def show
        render json: current_user, serializer: UserInfoSerializer, authorization: current_token.authorization
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
