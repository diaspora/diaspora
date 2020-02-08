# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < Api::V1::BaseController
      BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

      before_action do
        require_access_token %w[notifications]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Notification with provided guid could not be found"
      end

      def show
        notification = service.get_by_guid(params[:id])

        if notification
          render json: NotificationPresenter.new(notification).as_api_json
        else
          render_error 404, "Notification with provided guid could not be found"
        end
      end

      def index
        after_date = Date.iso8601(params[:only_after]) if params.has_key?(:only_after)

        notifications_query = service.index(BOOLEAN_TYPE.cast(params[:only_unread]), after_date)
        notifications_page = time_pager(notifications_query).response
        notifications_page[:data] = notifications_page[:data].map do |note|
          NotificationPresenter.new(note, default_serializer_options).as_api_json
        end
        render_paged_api_response notifications_page
      rescue ArgumentError
        render_error 422, "Could not process the notifications request"
      end

      def update
        read = BOOLEAN_TYPE.cast(params.require(:read))
        if service.update_status_by_guid(params[:id], read)
          head :no_content
        else
          render_error 422, "Could not process the notifications request"
        end
      rescue ActionController::ParameterMissing
        render_error 422, "Could not process the notifications request"
      end

      private

      def service
        @service ||= NotificationService.new(current_user)
      end
    end
  end
end
