# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      protect_from_forgery unless: -> { request.format.json? }

      protected

      rescue_from Exception do |e|
        logger.error e.message
        logger.error e.backtrace.join("\n")
        render json: error_body(500, e.message), status: :internal_server_error
      end

      rescue_from Rack::OAuth2::Server::Resource::Forbidden do |e|
        logger.error e.message
        render json: error_body(403, e.message), status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        logger.error e.message
        message = I18n.t("api.error.not_found")
        render json: error_body(404, message), status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        logger.error e.message
        render json: error_body(422, e.to_s), status: :unprocessable_entity
      end

      rescue_from ActionController::ParameterMissing do |e|
        logger.error e.message
        message = I18n.t("api.error.wrong_parameters") + ": " + e.message
        render json: error_body(422, message), status: :unprocessable_entity
      end

      def error_body(code, message)
        {code: code, message: message}
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end

      def index_pager(query)
        Api::Paging::RestPaginatorBuilder.new(query, request).index_pager(params)
      end

      def render_paged_api_response(page)
        link_header = []
        link_header << %(<#{page[:links][:next]}>; rel="next") if page[:links][:next]
        link_header << %(<#{page[:links][:previous]}>; rel="previous") if page[:links][:previous]
        response.set_header("Link", link_header.join(", ")) if link_header.present?

        render json: page[:data]
      end

      def render_error(code, message)
        render json: {code: code, message: message}, status: code
      end

      def time_pager(query)
        Api::Paging::RestPaginatorBuilder.new(query, request).time_pager(params)
      end

      def private_read?
        access_token? %w[private:read]
      end

      def private_modify?
        access_token? %w[private:modify]
      end
    end
  end
end
