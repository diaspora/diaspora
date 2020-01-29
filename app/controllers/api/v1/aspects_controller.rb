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
        aspects_page[:data] = aspects_page[:data].map {|a| aspect_as_json(a, false) }
        render_paged_api_response aspects_page
      end

      def show
        aspect = current_user.aspects.where(id: params[:id]).first
        if aspect
          render json: aspect_as_json(aspect, true)
        else
          render_error 404, I18n.t("api.endpoint_errors.aspects.not_found")
        end
      end

      def create
        params.require(%i[name])
        aspect = current_user.aspects.build(name: params[:name])
        if aspect&.save
          render json: aspect_as_json(aspect, true)
        else
          render_error 422, I18n.t("api.endpoint_errors.aspects.cant_create")
        end
      rescue ActionController::ParameterMissing
        render_error 422, I18n.t("api.endpoint_errors.aspects.cant_create")
      end

      def update
        aspect = current_user.aspects.where(id: params[:id]).first

        if !aspect
          render_error 404, I18n.t("api.endpoint_errors.aspects.cant_update")
        elsif aspect.update!(aspect_params(true))
          render json: aspect_as_json(aspect, true)
        else
          render_error 422, I18n.t("api.endpoint_errors.aspects.cant_update")
        end
      rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
        render_error 422, I18n.t("api.endpoint_errors.aspects.cant_update")
      end

      def destroy
        aspect = current_user.aspects.where(id: params[:id]).first
        if aspect&.destroy
          head :no_content
        else
          render_error 422, I18n.t("api.endpoint_errors.aspects.cant_delete")
        end
      end

      private

      def aspect_params(allow_order=false)
        parameters = params.permit(:name)
        parameters[:order_id] = params[:order] if params.has_key?(:order) && allow_order

        parameters
      end

      def aspect_as_json(aspect, as_full)
        AspectPresenter.new(aspect).as_api_json(as_full)
      end
    end
  end
end
