# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      protected

      rescue_from Exception do |e|
        logger.error e.message
        logger.error e.backtrace.join("\n")
        render json: error_body(500, e.message), status: 500
      end

      rescue_from Rack::OAuth2::Server::Resource::Forbidden do |e|
        logger.error e.message
        render json: error_body(403, e.message), status: 403
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        logger.error e.message
        message = I18n.t("api.error.not_found")
        render json: error_body(404, message), status: 404
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        logger.error e.message
        render json: error_body(422, e.to_s), status: 422
      end

      rescue_from ActionController::ParameterMissing do |e|
        logger.error e.message
        message = I18n.t("api.error.wrong_parameters") + ": " + e.message
        render json: error_body(422, message), status: 422
      end

      def error_body(code, message)
        {code: code, message: message}
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
