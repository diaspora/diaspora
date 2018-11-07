# frozen_string_literal: true

module Api
  module V1
    class MessagesController < Api::V1::BaseController
      before_action only: %i[create] do
        require_access_token %w[read write]
      end

      before_action only: %i[index] do
        require_access_token %w[read]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json:   I18n.t("api.endpoint_errors.conversations.not_found"), status: :not_found
      end

      def create
        conversation = conversation_service.find!(params[:conversation_id])
        text = params.require(:body)
        message = current_user.build_message(conversation, text: text)
        message.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(current_user, message)
        render json: message_json(message), status: :created
      rescue ActionController::ParameterMissing
        render json:   I18n.t("api.endpoint_errors.conversations.cant_process"), status: :unprocessable_entity
      end

      def index
        conversation = conversation_service.find!(params[:conversation_id])
        conversation.set_read(current_user)
        render(
          json:   conversation.messages.map {|x| message_json(x) },
          status: :created
        )
      end

      def conversation_service
        ConversationService.new(current_user)
      end

      def message_json(message)
        MessagePresenter.new(message).as_api_json
      end
    end
  end
end
