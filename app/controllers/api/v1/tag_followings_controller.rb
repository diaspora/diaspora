# frozen_string_literal: true

module Api
  module V1
    class TagFollowingsController < Api::V1::BaseController
      before_action only: %i[index] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      rescue_from StandardError do
        render json: I18n.t("api.endpoint_errors.tags.cant_process"), status: :bad_request
      end

      def index
        render json: tag_followings_service.index.map(&:name)
      end

      def create
        tag_followings_service.create(params.require(:name))
        head :no_content
      end

      def destroy
        tag_followings_service.destroy_by_name(params.require(:id))
        head :no_content
      end

      private

      def tag_followings_service
        TagFollowingService.new(current_user)
      end
    end
  end
end
