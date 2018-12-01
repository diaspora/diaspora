# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      before_action do
        require_access_token %w[read]
      end

      rescue_from ActionController::ParameterMissing, RuntimeError do
        render json: I18n.t("api.endpoint_errors.search.cant_process"), status: :unprocessable_entity
      end

      def user_index
        parameters = params.permit(:tag, :name_or_handle)
        raise RuntimeError if parameters.keys.length != 1
        people = if params.has_key?(:tag)
                   Person.profile_tagged_with(params[:tag])
                 else
                   Person.search(params[:name_or_handle], current_user)
                 end
        render json: people.map {|p| PersonPresenter.new(p).as_api_json }
      end

      def post_index
        posts = Stream::Tag.new(current_user, params.require(:tag)).posts
        render json: posts.map {|p| PostPresenter.new(p).as_api_response }
      end
    end
  end
end
