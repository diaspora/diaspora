# frozen_string_literal: true

module Api
  module V1
    class PostsController < Api::V1::BaseController
      include PostsHelper

      before_action only: :show do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      def show
        mark_notifications =
          params[:mark_notifications].present? && params[:mark_notifications]
        post = post_service.find!(params[:id])
        post_service.mark_user_notifications(post.id) if mark_notifications
        render json: post_as_json(post)
      end

      def create
        status_service = StatusMessageCreationService.new(current_user)
        @status_message = status_service.create(normalized_params)
        render json: PostPresenter.new(@status_message, current_user)
      end

      def destroy
        post_service.destroy(params[:id])
        head :no_content
      end

      def normalized_params
        params.permit(
          :location_address,
          :location_coords,
          :poll_question,
          status_message: %i[text provider_display_name],
          poll_answers:   []
        ).to_h.merge(
          services:   [*params[:services]].compact,
          aspect_ids: normalize_aspect_ids,
          public:     [*params[:aspect_ids]].first == "public",
          photos:     [*params[:photos]].compact
        )
      end

      def normalize_aspect_ids
        aspect_ids = [*params[:aspect_ids]]
        if aspect_ids.first == "all_aspects"
          current_user.aspect_ids
        else
          aspect_ids
        end
      end

      def post_service
        @post_service ||= PostService.new(current_user)
      end

      def post_as_json(post)
        PostPresenter.new(post).as_api_response
      end
    end
  end
end
