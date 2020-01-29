# frozen_string_literal: true

module Api
  module V1
    class TagFollowingsController < Api::V1::BaseController
      before_action except: %i[create destroy] do
        require_access_token %w[tags:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[tags:modify]
      end

      def index
        render json: tag_followings_service.index.pluck(:name)
      end

      def create
        tag_followings_service.create(params.require(:name))
        head :no_content
      rescue TagFollowingService::DuplicateTag
        render_error 409, "Already following this tag"
      rescue StandardError
        render_error 422, "Failed to process the tag followings request"
      end

      def destroy
        tag_followings_service.destroy_by_name(params.require(:id))
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render_error 410, "Not following this tag"
      end

      private

      def tag_followings_service
        @tag_followings_service ||= TagFollowingService.new(current_user)
      end
    end
  end
end
