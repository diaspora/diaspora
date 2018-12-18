# frozen_string_literal: true

module Api
  module V1
    class LikesController < Api::V1::BaseController
      before_action do
        require_access_token %w[interactions public:read]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("api.endpoint_errors.likes.user_not_allowed_to_like"), status: :unprocessable_entity
      end

      def show
        post = post_service.find!(params[:post_id])
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?
        likes_query = like_service.find_for_post(params[:post_id])
        likes_page = index_pager(likes_query).response
        likes_page[:data] = likes_page[:data].map {|x| like_json(x) }
        render json: likes_page
      end

      def create
        post = post_service.find!(params[:post_id])
        raise ActiveRecord::RecordInvalid unless post.public? || private_modify?
        like_service.create(params[:post_id])
      rescue ActiveRecord::RecordInvalid => e
        return render json: I18n.t("api.endpoint_errors.likes.like_exists"), status: :unprocessable_entity if
          e.message == "Validation failed: Target has already been taken"
        raise
      else
        head :no_content
      end

      def destroy
        post = post_service.find!(params[:post_id])
        raise ActiveRecord::RecordInvalid unless post.public? || private_modify?
        success = like_service.unlike_post(params[:post_id])
        if success
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.likes.no_like"), status: :not_found
        end
      end

      private

      def like_service
        @like_service ||= LikeService.new(current_user)
      end

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def like_json(like)
        LikesPresenter.new(like).as_api_json
      end
    end
  end
end
