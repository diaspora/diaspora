module Api
  module V0
    class PostsController < Api::V0::BaseController
      include PostsHelper

      before_action only: :show do
        require_access_token Api::OpenidConnect::Scope.find_by(name: "read")
      end

      before_action only: :destroy do
        require_access_token Api::OpenidConnect::Scope.find_by(name: "read"),
                             Api::OpenidConnect::Scope.find_by(name: "write")
      end

      def show
        posts_services = PostService.new(id: params[:id], user: current_user)
        posts_services.mark_user_notifications
        render json: posts_services.present_json
      end

      def destroy
        post_service = PostService.new(id: params[:id], user: current_user)
        post_service.retract_post
        render nothing: true, status: 204
      end
    end
  end
end
