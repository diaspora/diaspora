# frozen_string_literal: true

module Api
  module V1
    class CommentsController < Api::V1::BaseController
      before_action except: %i[create destroy] do
        require_access_token %w[public:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[interactions public:read]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Post with provided guid could not be found"
      end

      rescue_from ActiveRecord::RecordInvalid do
        render_error 422, "User is not allowed to comment"
      end

      def create
        find_post
        comment = comment_service.create(params.require(:post_id), params.require(:body))
      rescue ActiveRecord::RecordNotFound
        render_error 404, "Post with provided guid could not be found"
      else
        render json: comment_as_json(comment), status: :created
      end

      def index
        find_post
        comments_query = comment_service.find_for_post(params.require(:post_id))
        params[:after] = Time.utc(1900).iso8601 if params.permit(:before, :after).empty?

        comments_page = time_pager(comments_query).response
        comments_page[:data] = comments_page[:data].map {|x| comment_as_json(x) }
        render_paged_api_response comments_page
      end

      def destroy
        find_post
        if comment_and_post_validate(params.require(:post_id), params[:id])
          comment_service.destroy!(params[:id])
          head :no_content
        end
      rescue ActiveRecord::RecordInvalid
        render_error 403, "User not allowed to delete the comment"
      end

      def report
        find_post
        post_guid = params.require(:post_id)
        comment_guid = params.require(:comment_id)
        return unless comment_and_post_validate(post_guid, comment_guid)

        reason = params.require(:reason)
        comment = comment_service.find!(comment_guid)
        report = current_user.reports.new(
          item_id:   comment.id,
          item_type: "Comment",
          text:      reason
        )
        if report.save
          head :no_content
        else
          render_error 409, "This item already has been reported by this user"
        end
      end

      private

      def comment_and_post_validate(post_guid, comment_guid)
        if !comment_exists(comment_guid)
          render_error 404, "Comment not found for the given post"
          false
        elsif !comment_is_for_post(post_guid, comment_guid)
          render_error 404, "Comment not found for the given post"
          false
        else
          true
        end
      end

      def comment_is_for_post(post_guid, comment_guid)
        comments = comment_service.find_for_post(post_guid)
        comment = comments.find {|comment| comment[:guid] == comment_guid }
        comment ? true : false
      end

      def comment_exists(comment_guid)
        comment = comment_service.find!(comment_guid)
        comment ? true : false
      rescue ActiveRecord::RecordNotFound
        false
      end

      def comment_service
        @comment_service ||= CommentService.new(current_user)
      end

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def comment_as_json(comment)
        CommentPresenter.new(comment, current_user).as_api_response
      end

      def find_post
        post = post_service.find!(params[:post_id])
        return post if post.public? || private_read?

        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
