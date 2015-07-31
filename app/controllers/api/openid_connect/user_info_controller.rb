module Api
  module OpenidConnect
    class UserInfoController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      before_action do
        require_access_token Api::OpenidConnect::Scope.find_by(name: "openid")
      end

      def show
        render json: current_user, serializer: UserInfoSerializer
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
