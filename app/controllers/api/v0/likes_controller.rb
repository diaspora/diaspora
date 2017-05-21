module Api
  module V0
    class LikesController < Api::V0::BaseController
      before_action only: %i(create destroy) do
        require_access_token %w(read write)
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("likes.not_found"), status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do
        render json: I18n.t("likes.create.fail"), status: 404
      end

      def create
        @like = current_user.like!(target) if target
        if @like
          render json: @like.as_api_response(:backbone), status: 201
        else
          render nothing: true, status: 422
        end
      end

      def destroy
        @like = Like.find_by_id_and_author_id!(params[:id], current_user.person.id)
        current_user.retract(@like)
        render nothing: true, status: 204
      end

      private

      def target
        @target ||= if params[:post_id]
                      current_user.find_visible_shareable_by_id(Post, params[:post_id]).tap do |post|
                        raise(ActiveRecord::RecordNotFound.new) unless post
                      end
                    else
                      Comment.find(params[:comment_id]).tap do |comment|
                        shareable = current_user.find_visible_shareable_by_id(Post, comment.commentable_id)
                        raise(ActiveRecord::RecordNotFound.new) unless shareable
                      end
                    end
      end
    end
  end
end
