# frozen_string_literal: true

module Api
  module V1
    class LikesController < Api::V1::BaseController
      before_action only: %i[show] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("api.endpoint_errors.likes.user_not_allowed_to_like"), status: :not_found
      end

      def show
        likes = like_service.find_for_post(params[:post_id])
        render json: likes.map {|x| like_json(x) }
      end

      def create
        like_service.create(params[:post_id])
      rescue ActiveRecord::RecordInvalid => e
        return render json: I18n.t("api.endpoint_errors.likes.like_exists"), status: :unprocessable_entity if
          e.message == "Validation failed: Target has already been taken"
        raise
      else
        head :no_content
      end

      def destroy
        success = like_service.unlike_post(params[:post_id])
        if success
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.likes.no_like"), status: :not_found
        end
      end

      def like_service
        @like_service ||= LikeService.new(current_user)
      end

      private

      def like_json(like)
        LikesPresenter.new(like).as_api_json
      end
    end
  end
end
