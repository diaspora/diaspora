# frozen_string_literal: true

module Api
  module V1
    class LikesController < Api::V1::BaseController
      before_action do
        require_access_token %w[public:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[interactions]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Post with provided guid could not be found"
      end

      rescue_from ActiveRecord::RecordInvalid do
        render_error 422, "User is not allowed to like"
      end

      def show
        post = post_service.find!(params.require(:post_id))
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?

        likes_query = like_service.find_for_post(params[:post_id])
        likes_page = index_pager(likes_query).response
        likes_page[:data] = likes_page[:data].map {|x| like_json(x) }
        render_paged_api_response likes_page
      end

      def create
        post = post_service.find!(params.require(:post_id))
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?

        like_service.create(params[:post_id])
      rescue ActiveRecord::RecordInvalid => e
        if e.message == "Validation failed: Target has already been taken"
          return render_error 409, "Like already exists"
        end

        raise
      else
        head :no_content
      end

      def destroy
        post = post_service.find!(params.require(:post_id))
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?

        success = like_service.unlike_post(params[:post_id])
        if success
          head :no_content
        else
          render_error 410, "Like doesn’t exist"
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
