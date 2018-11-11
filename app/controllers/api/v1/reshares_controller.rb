# frozen_string_literal: true

module Api
  module V1
    class ResharesController < Api::V1::BaseController
      before_action only: %i[show] do
        require_access_token %w[read]
      end

      before_action only: %i[create] do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      rescue_from Diaspora::NonPublic do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      def show
        reshares = reshare_service.find_for_post(params[:post_id]).map do |r|
          {guid: r.guid, author: PersonPresenter.new(r.author).as_api_json}
        end
        render json: reshares
      end

      def create
        reshare = reshare_service.create(params[:post_id])
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid, RuntimeError
        render plain: I18n.t("reshares.create.error"), status: :unprocessable_entity
      else
        render json: PostPresenter.new(reshare, current_user).as_api_response
      end

      def reshare_service
        @reshare_service ||= ReshareService.new(current_user)
      end
    end
  end
end
