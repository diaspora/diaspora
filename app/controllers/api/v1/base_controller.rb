# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      protected

      rescue_from Exception do |e|
        logger.error e.message
        render json: {error: e.message}, status: 500
      end

      rescue_from ActiveRecord::RecordNotFound do
        logger.error e.message
        render json: {error: I18n.t("api.error.not_found")}, status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        logger.error e.message
        render json: {error: e.to_s}, status: 400
      end

      rescue_from ActionController::ParameterMissing do |e|
        logger.error e.message
        render json: {
          error:   I18n.t("api.error.wrong_parameters"),
          message: e.message
        }, status: 400
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
