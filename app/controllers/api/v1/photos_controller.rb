# frozen_string_literal: true

module Api
  module V1
    class PhotosController < Api::V1::BaseController
      before_action except: %i[create destroy] do
        require_access_token %w[public:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[public:modify]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Photo with provided guid could not be found"
      end

      def index
        query = if private_read?
                  current_user.photos
                else
                  current_user.photos.where(public: true)
                end
        photos_page = time_pager(query).response
        photos_page[:data] = photos_page[:data].map {|photo| photo_json(photo) }
        render_paged_api_response photos_page
      end

      def show
        photo = photo_service.visible_photo(params.require(:id))
        raise ActiveRecord::RecordNotFound unless photo

        raise ActiveRecord::RecordNotFound unless photo.public? || private_read?

        render json: photo_json(photo)
      end

      def create
        image = params.require(:image)
        public_photo = params.has_key?(:aspect_ids)
        raise RuntimeError unless public_photo || private_modify?

        base_params = params.permit(:aspect_ids, :pending, :set_profile_photo)
        photo = photo_service.create_from_params_and_file(base_params, image)
        raise RuntimeError unless photo

        render json: photo_json(photo)
      rescue CarrierWave::IntegrityError, ActionController::ParameterMissing, RuntimeError
        render_error 422, "Failed to create the photo"
      end

      def destroy
        photo = current_user.photos.where(guid: params[:id]).first
        raise ActiveRecord::RecordNotFound unless photo

        raise ActiveRecord::RecordNotFound unless photo.public? || private_modify?

        if current_user.retract(photo)
          head :no_content
        else
          render_error 422, "Not allowed to delete the photo"
        end
      end

      private

      def photo_service
        @photo_service ||= PhotoService.new(current_user)
      end

      def photo_json(photo)
        PhotoPresenter.new(photo).as_api_json(true)
      end
    end
  end
end
