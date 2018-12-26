# frozen_string_literal: true

module Api
  module V1
    class AspectsController < Api::V1::BaseController
      before_action except: %i[create update destroy] do
        require_access_token %w[contacts:read]
      end

      before_action only: %i[create update destroy] do
        require_access_token %w[contacts:modify]
      end

      def index
        aspects_query = current_user.aspects
        aspects_page = index_pager(aspects_query).response
        aspects_page[:data] = aspects_page[:data].map {|a| AspectPresenter.new(a).as_api_json(false) }
        render json: aspects_page
      end

      def show
        aspect = current_user.aspects.where(id: params[:id]).first
        if aspect
          render json: AspectPresenter.new(aspect).as_api_json(true)
        else
          render json: I18n.t("api.endpoint_errors.aspects.not_found"), status: :not_found
        end
      end

      def create
        params.require(%i[name chat_enabled])
        aspect = current_user.aspects.build(name: params[:name], chat_enabled: params[:chat_enabled])
        if aspect&.save
          render json: AspectPresenter.new(aspect).as_api_json(true)
        else
          render json: I18n.t("api.endpoint_errors.aspects.cant_create"), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: I18n.t("api.endpoint_errors.aspects.cant_create"), status: :unprocessable_entity
      end

      def update
        aspect = current_user.aspects.where(id: params[:id]).first

        if !aspect
          render json: I18n.t("api.endpoint_errors.aspects.cant_update"), status: :not_found
        elsif aspect.update!(aspect_params(true))
          render json: AspectPresenter.new(aspect).as_api_json(true)
        else
          render json: I18n.t("api.endpoint_errors.aspects.cant_update"), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
        render json: I18n.t("api.endpoint_errors.aspects.cant_update"), status: :unprocessable_entity
      end

      def destroy
        aspect = current_user.aspects.where(id: params[:id]).first
        if aspect&.destroy
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.aspects.cant_delete"), status: :unprocessable_entity
        end
      end

      private

      def aspect_params(allow_order=false)
        parameters = params.permit(:name, :chat_enabled)
        parameters[:order_id] = params[:order] if params.has_key?(:order) && allow_order
        parameters
      end
    end
  end
end
