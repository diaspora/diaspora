# frozen_string_literal: true

module Api
  module V1
    class PostInteractionsController < Api::V1::BaseController
      include PostsHelper

      before_action do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      def subscribe
        post = post_service.find!(params[:post_id])
        current_user.participate!(post)
        head :no_content
      rescue ActiveRecord::RecordInvalid
        render json: I18n.t("api.endpoint_errors.interactions.cant_subscribe"), status: :unprocessable_entity
      end

      def hide
        post = post_service.find!(params[:post_id])
        current_user.toggle_hidden_shareable(post)
        head :no_content
      end

      def mute
        post = post_service.find!(params[:post_id])
        participation = current_user.participations.find_by!(target_id: post.id)
        participation.destroy
        head :no_content
      end

      def report
        reason = params.require(:reason)
        post = post_service.find!(params[:post_id])
        report = current_user.reports.new(
          item_id:   post.id,
          item_type: "Post",
          text:      reason
        )
        if report.save
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.posts.cant_report"), status: :conflict
        end
      rescue ActionController::ParameterMissing
        render json: I18n.t("api.endpoint_errors.posts.cant_report"), status: :unprocessable_entity
      end

      def vote
        begin
          post = post_service.find!(params[:post_id])
        rescue ActiveRecord::RecordNotFound
          render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
          return
        end
        poll_vote = poll_service.vote(post.id, params[:poll_answer_id])
        if poll_vote
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.interactions.cant_vote"), status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
        render json: I18n.t("api.endpoint_errors.interactions.cant_vote"), status: :unprocessable_entity
      end

      private

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def poll_service
        @poll_service ||= PollParticipationService.new(current_user)
      end
    end
  end
end
