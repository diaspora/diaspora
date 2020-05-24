# frozen_string_literal: true

module Api
  module V1
    class MessagesController < Api::V1::BaseController
      before_action do
        require_access_token %w[conversations]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Conversation with provided guid could not be found"
      end

      def create
        conversation = conversation_service.find!(params.require(:conversation_id))
        text = params.require(:body)
        message = current_user.build_message(conversation, text: text)
        message.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(current_user, message)
        render json: message_json(message), status: :created
      rescue ActionController::ParameterMissing
        render_error 422, "Couldn’t accept or process the conversation"
      end

      def index
        conversation = conversation_service.find!(params.require(:conversation_id))
        conversation.set_read(current_user)
        messages_page = index_pager(conversation.messages).response
        messages_page[:data] = messages_page[:data].map {|x| message_json(x) }
        render_paged_api_response messages_page
      end

      private

      def conversation_service
        ConversationService.new(current_user)
      end

      def message_json(message)
        MessagePresenter.new(message).as_api_json
      end
    end
  end
end
