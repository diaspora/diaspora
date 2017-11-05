# frozen_string_literal: true

module Api
  module V0
    class CommentsController < Api::V0::BaseController
      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("comments.not_found"), status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("comments.create.fail"), status: 404
      end

      def create
        @comment = comment_service.create(params[:post_id], params[:text])
        render json: CommentPresenter.new(@comment), status: 201
      end

      def destroy
        if comment_service.destroy(params[:id])
          head :no_content
        else
          render json: I18n.t("comments.destroy.fail"), status: 403
        end
      end

      def comment_service
        @comment_service ||= CommentService.new(current_user)
      end
    end
  end
end
