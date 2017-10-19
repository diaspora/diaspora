# frozen_string_literal: true

module Api
  module V0
    class PostsController < Api::V0::BaseController
      include PostsHelper

      before_action only: :show do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      def show
        posts_services = PostService.new(id: params[:id], user: current_user)
        posts_services.mark_user_notifications unless params[:mark_notifications] == "false"
        render json: posts_services.present_api_json
      end

      def create
        @status_message = StatusMessageCreationService.new(params, current_user).status_message
        render json: PostPresenter.new(@status_message, current_user)
      end

      def destroy
        post_service = PostService.new(id: params[:id], user: current_user)
        post_service.retract_post
        render nothing: true, status: 204
      end
    end
  end
end
