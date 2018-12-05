# frozen_string_literal: true

module Api
  module V1
    class PhotosController < Api::V1::BaseController
      before_action except: %i[create destroy] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.photos.not_found"), status: :not_found
      end

      def index
        photos_page = time_pager(current_user.photos).response
        photos_page[:data] = photos_page[:data].map {|photo| PhotoPresenter.new(photo).as_api_json(true) }
        render json: photos_page
      end

      def show
        photo = photo_service.visible_photo(params.require(:id))
        raise ActiveRecord::RecordNotFound unless photo
        render json: PhotoPresenter.new(photo).as_api_json(true)
      end

      def create
        image = params.require(:image)
        base_params = params.permit(:aspect_ids, :pending, :set_profile_photo)
        photo = photo_service.create_from_params_and_file(base_params, image)
        raise RuntimeError unless photo
        render json: PhotoPresenter.new(photo).as_api_json(true)
      rescue CarrierWave::IntegrityError, ActionController::ParameterMissing, RuntimeError
        render json: I18n.t("api.endpoint_errors.photos.failed_create"), status: :unprocessable_entity
      end

      def destroy
        photo = current_user.photos.where(guid: params[:id]).first
        raise ActiveRecord::RecordNotFound unless photo
        if current_user.retract(photo)
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.photos.failed_delete"), status: :unprocessable_entity
        end
      end

      private

      def photo_service
        @photo_service ||= PhotoService.new(current_user)
      end
    end
  end
end
