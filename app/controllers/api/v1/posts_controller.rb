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
        render_error 404, "Post with provided guid could not be found"
      end

      def show
        post = post_service.find!(params[:id])
        raise ActiveRecord::RecordNotFound unless post.public? || private_read?

        render json: post_as_json(post)
      end

      def create
        creation_params = normalized_create_params
        raise StandardError unless creation_params[:public] || private_modify?

        @status_message = creation_service.create(creation_params)
        render json: PostPresenter.new(@status_message, current_user).as_api_response
      rescue StandardError
        render_error 422, "Failed to create the post"
      end

      def destroy
        post_service.destroy(params[:id], private_modify?)
        head :no_content
      rescue Diaspora::NotMine, Diaspora::NonPublic
        render_error 403, "Not allowed to delete the post"
      end

      private

      def normalized_create_params
        mapped_parameters = {
          status_message: {
            text: params[:body]
          },
          public:         params.require(:public),
          aspect_ids:     normalize_aspect_ids(params.permit(aspects: []))
        }
        add_location_params(mapped_parameters)
        add_poll_params(mapped_parameters)
        add_photo_ids(mapped_parameters)
        mapped_parameters
      end

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

        photos = photo_guids.map {|guid| Photo.find_by!(guid: guid) }
                            .select {|p| p.author_id == current_user.person.id && p.pending }
        raise InvalidArgument if photos.length != photo_guids.length

        mapped_parameters[:photos] = photos
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

      def creation_service
        @creation_service ||= StatusMessageCreationService.new(current_user)
      end

      def post_as_json(post)
        PostPresenter.new(post, current_user).as_api_response
      end
    end
  end
end
