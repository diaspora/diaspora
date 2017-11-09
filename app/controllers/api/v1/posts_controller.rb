# frozen_string_literal: true

module Api
  module V0
    class PostsController < Api::V0::BaseController
      include PostsHelper

      before_action only: :show do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      def show
        posts_services = PostService.new(id: params[:id], user: current_user)
        posts_services.mark_user_notifications unless params[:mark_notifications] == "false"
        render json: posts_services.present_api_json
      end

      def create
        @status_message = StatusMessageCreationService.new(current_user).create(normalized_params)
        render json: PostPresenter.new(@status_message, current_user)
      end

      def destroy
        post_service = PostService.new(id: params[:id], user: current_user)
        post_service.retract_post
        render nothing: true, status: 204
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
    end
  end
end
