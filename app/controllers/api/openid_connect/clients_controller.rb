module Api
  module OpenidConnect
    class ClientsController < ApplicationController
      rescue_from OpenIDConnect::HttpError do |e|
        http_error_page_as_json(e)
      end

      rescue_from OpenIDConnect::ValidationFailed, ActiveRecord::RecordInvalid do |e|
        validation_fail_as_json(e)
      end

      def create
        registrar = OpenIDConnect::Client::Registrar.new(request.url, params)
        client = Api::OpenidConnect::OAuthApplication.register! registrar
        render json: client.as_json(root: false)
      end

      private

      def http_error_page_as_json(e)
        render json:
                 {
                   error:             :invalid_request,
                   error_description: e.message
                 }, status: 400
      end

      def validation_fail_as_json(e)
        render json:
                 {
                   error:             :invalid_client_metadata,
                   error_description: e.message
                 }, status: 400
      end
    end
  end
end
