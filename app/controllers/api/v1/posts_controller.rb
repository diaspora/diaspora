# frozen_string_literal: true

module Api
  module V1
    class PostsController < Api::V1::BaseController
      include PostsHelper

      before_action except: %i[create destroy] do
        require_access_token %w[public:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[public:modify]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.posts.post_not_found"), status: :not_found
      end

      def show
        post = post_service.find!(params[:id])
        raise ActiveRecord::RecordNotFound unless post.public? || private_read?
        render json: post_as_json(post)
      end

      def create
        raise StandardError unless params.require(:public) || private_modify?
        status_service = StatusMessageCreationService.new(current_user)
        creation_params = normalized_create_params
        @status_message = status_service.create(creation_params)
        render json: PostPresenter.new(@status_message, current_user).as_api_response
      rescue StandardError
        render json: I18n.t("api.endpoint_errors.posts.failed_create"), status: :unprocessable_entity
      end

      def destroy
        post_service.destroy(params[:id], private_modify?)
        head :no_content
      rescue Diaspora::NotMine, Diaspora::NonPublic
        render json: I18n.t("api.endpoint_errors.posts.failed_delete"), status: :forbidden
      end

      def normalized_create_params
        mapped_parameters = {
          status_message: {
            text: params.require(:body)
          },
          public:         params.require(:public),
          aspect_ids:     normalize_aspect_ids(params.permit(aspects: []))
        }
        add_location_params(mapped_parameters)
        add_poll_params(mapped_parameters)
        add_photo_ids(mapped_parameters)
        mapped_parameters
      end

      private

      def add_location_params(mapped_parameters)
        return unless params.has_key?(:location)
        location = params.require(:location)
        mapped_parameters[:location_address] = location[:address]
        mapped_parameters[:location_coords] = "#{location[:lat]},#{location[:lng]}"
      end

      def add_photo_ids(mapped_parameters)
        return unless params.has_key?(:photos)
        photo_guids = params[:photos]
        return if photo_guids.empty?
        photo_ids = photo_guids.map {|guid| Photo.find_by!(guid: guid) }
        raise InvalidArgument if photo_ids.length != photo_guids.length
        mapped_parameters[:photos] = photo_ids
      end

      def add_poll_params(mapped_parameters)
        return unless params.has_key?(:poll)
        poll_data = params.require(:poll)
        question = poll_data[:question]
        answers = poll_data[:poll_answers]
        raise InvalidArgument if question.blank?
        raise InvalidArgument if answers.empty?
        answers.each do |a|
          raise InvalidArgument if a.blank?
        end
        mapped_parameters[:poll_question] = question
        mapped_parameters[:poll_answers] = answers
      end

      def normalize_aspect_ids(aspects)
        aspects.empty? ? [] : aspects[:aspects]
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
