# frozen_string_literal: true

module Api
  module V1
    class CommentsController < Api::V1::BaseController
      before_action only: %i[index report] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      def create
        @comment = comment_service.create(params[:post_id], params[:body])
        comment = comment_as_json(@comment)
        render json: comment, status: 201
      end

      def index
        comments = comment_service.find_for_post(params[:post_id])
        render json: comments.map {|x| comment_as_json(x) }
      end

      def destroy
        comment_service.destroy!(params[:id])
        head :no_content
      end

      def report
        comment_guid = params.require(:comment_id)
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
          render json: {error: I18n.t("report.status.failed")}, status: 500
        end
      end

      def comment_service
        @comment_service ||= CommentService.new(current_user)
      end

      def comment_as_json(comment)
        CommentPresenter.new(comment).as_api_response
      end
    end
  end
end
