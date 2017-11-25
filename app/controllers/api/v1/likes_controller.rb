# frozen_string_literal: true

module Api
  module V1
    class LikesController < Api::V1::BaseController
      before_action only: %i[create destroy] do
        require_access_token %w[write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("likes.not_found"), status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("likes.create.fail"), status: 404
      end

      def create
        like_service.create(params[:post_id])
        head :no_content, status: 204
      end

      def destroy
        like_service.unlike_post(params[:post_id])
        head :no_content, status: 204
      end

      def like_service
        @like_service ||= LikeService.new(current_user)
      end
    end
  end
end
