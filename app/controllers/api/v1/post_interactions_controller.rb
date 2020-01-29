# frozen_string_literal: true

module Api
  module V1
    class PostInteractionsController < Api::V1::BaseController
      include PostsHelper

      before_action do
        require_access_token %w[public:read interactions]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, I18n.t("api.endpoint_errors.posts.post_not_found")
      end

      def subscribe
        post = find_post
        current_user.participate!(post)
        head :no_content
      rescue ActiveRecord::RecordInvalid
        render_error 422, I18n.t("api.endpoint_errors.interactions.cant_subscribe")
      end

      def hide
        post = find_post
        current_user.toggle_hidden_shareable(post)
        head :no_content
      end

      def mute
        post = find_post
        participation = current_user.participations.find_by!(target_id: post.id)
        participation.destroy
        head :no_content
      end

      def report
        reason = params.require(:reason)
        post = find_post
        report = current_user.reports.new(
          item_id:   post.id,
          item_type: "Post",
          text:      reason
        )
        if report.save
          head :no_content
        else
          render_error 409, I18n.t("api.endpoint_errors.posts.cant_report")
        end
      rescue ActionController::ParameterMissing
        render_error 422, I18n.t("api.endpoint_errors.posts.cant_report")
      end

      def vote
        post = find_post
        begin
          poll_vote = poll_service.vote(post.id, params[:poll_answer_id])
        rescue ActiveRecord::RecordNotFound
          # This, but not the find_post above, should return a 422,
          # we just keep poll_vote nil so it goes into the else below
        end
        if poll_vote
          head :no_content
        else
          render_error 422, I18n.t("api.endpoint_errors.interactions.cant_vote")
        end
      rescue ActiveRecord::RecordInvalid
        render_error 422, I18n.t("api.endpoint_errors.interactions.cant_vote")
      end

      private

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def poll_service
        @poll_service ||= PollParticipationService.new(current_user)
      end

      def find_post
        post = post_service.find!(params[:post_id])
        raise ActiveRecord::RecordNotFound unless post.public? || private_read?

        post
      end
    end
  end
end
