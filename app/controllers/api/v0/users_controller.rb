module Api
  module V0
    class UsersController < Api::V0::BaseController
      before_action do
        require_access_token Api::OpenidConnect::Scope.find_by(name: "read")
      end

      def show
        render json: current_user
      end
    end
  end
end
