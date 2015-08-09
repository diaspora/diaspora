module Api
  module V0
    class CommentsController < Api::V0::BaseController
      before_action only: :index do
        require_access_token %w(read)
      end

      before_action only: %i(create destroy) do
        require_access_token %w(read write)
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("comments.not_found"), status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("comments.create.fail"), status: 404
      end

      def index
        service = CommentService.new(post_id: params[:post_id], user: current_user)
        @comments = service.comments
        render json: CommentPresenter.as_collection(@comments), status: 200
      end

      def create
        @comment = CommentService.new(post_id: params[:post_id], text: params[:text], user: current_user).create_comment
        render json: CommentPresenter.new(@comment), status: 201
      end

      def destroy
        service = CommentService.new(comment_id: params[:id], user: current_user)
        if service.destroy_comment
          render json: I18n.t("comments.destroy.success", id: params[:id]), status: 200
        else
          render json: I18n.t("comments.destroy.fail"), status: 403
        end
      end
    end
  end
end
