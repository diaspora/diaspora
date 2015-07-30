module Api
  module V0
    class BaseController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
