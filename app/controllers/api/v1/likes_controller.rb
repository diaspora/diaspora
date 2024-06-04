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

        likes_query = find_likes

        return unless likes_query

        likes_page = index_pager(likes_query).response
        likes_page[:data] = likes_page[:data].map {|x| like_json(x) }
        render_paged_api_response likes_page
      end

      def create
        post = post_service.find!(params.require(:post_id))
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?

        if params[:comment_id].present?
          create_for_comment
        else
          create_for_post
        end
      rescue ActiveRecord::RecordInvalid => e
        if e.message == "Validation failed: Target has already been taken"
          return render_error 409, "Like already exists"
        end

        raise
      end

      def destroy
        post = post_service.find!(params.require(:post_id))
        raise ActiveRecord::RecordInvalid unless post.public? || private_read?

        if params[:comment_id].present?
          destroy_for_comment
        else
          destroy_for_post
        end
      end

      private

      def find_likes
        if params[:comment_id].present?
          return unless comment_and_post_validate(params[:post_id], params[:comment_id])

          like_service.find_for_comment(params[:comment_id])
        else
          like_service.find_for_post(params[:post_id])
        end
      end

      def like_service
        @like_service ||= LikeService.new(current_user)
      end

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def comment_service
        @comment_service ||= CommentService.new(current_user)
      end

      def like_json(like)
        LikesPresenter.new(like).as_api_json
      end

      def create_for_post
        like_service.create_for_post(params[:post_id])

        head :no_content
      end

      def create_for_comment
        return unless comment_and_post_validate(params[:post_id], params[:comment_id])

        like_service.create_for_comment(params[:comment_id])

        head :no_content
      end

      def destroy_for_post
        if like_service.unlike_post(params[:post_id])
          head :no_content
        else
          render_error 410, "Like doesn’t exist"
        end
      end

      def destroy_for_comment
        return unless comment_and_post_validate(params[:post_id], params[:comment_id])

        if like_service.unlike_comment(params[:comment_id])
          head :no_content
        else
          render_error 410, "Like doesn’t exist"
        end
      end

      def comment_and_post_validate(post_guid, comment_guid)
        if comment_is_for_post(post_guid, comment_guid)
          true
        else
          render_error 404, "Comment not found for the given post"
          false
        end
      end

      def comment_is_for_post(post_guid, comment_guid)
        comments = comment_service.find_for_post(post_guid)
        comments.exists?(guid: comment_guid)
      end
    end
  end
end
