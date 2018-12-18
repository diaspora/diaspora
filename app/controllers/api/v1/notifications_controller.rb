# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < Api::V1::BaseController
      before_action do
        require_access_token %w[notifications]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.notifications.not_found"), status: :not_found
      end

      def show
        notification = service.get_by_guid(params[:id])

        if notification
          render json: NotificationPresenter.new(notification).as_api_json(true)
        else
          render json: I18n.t("api.endpoint_errors.notifications.not_found"), status: :not_found
        end
      end

      def index
        after_date = Date.iso8601(params[:only_after]) if params.has_key?(:only_after)
        notifications_query = service.index(params[:only_unread], after_date)
        notifications_page = time_pager(notifications_query).response
        notifications_page[:data] = notifications_page[:data].map do |note|
          NotificationPresenter.new(note, default_serializer_options).as_api_json
        end
        render json: notifications_page
      rescue ArgumentError
        render json: I18n.t("api.endpoint_errors.notifications.cant_process"), status: :unprocessable_entity
      end

      def update
        read = ActiveModel::Type::Boolean.new.cast(params.require(:read))
        if service.update_status_by_guid(params[:id], read)
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.notifications.cant_process"), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: I18n.t("api.endpoint_errors.notifications.cant_process"), status: :unprocessable_entity
      end

      private

      def service
        @service ||= NotificationService.new(current_user)
      end
    end
  end
end
