module Api
  module V0
    class MessagesController < Api::V0::BaseController
      before_action only: %i(create) do
        require_access_token %w(read write)
      end

      before_action only: %i(index) do
        require_access_token %w(read)
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: {error: I18n.t("conversations.not_found")}, status: 404
      end

      def create
        conversation = conversation_service.find!(params[:conversation_id])
        opts = params.require(:body)
        message = current_user.build_message(conversation, {
            :text => opts[:body]
        })
        message.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(current_user, message)
        render json: message_json(message), status: 201
      end

      def index
        conversation = conversation_service.find!(params[:conversation_id])
        render json: conversation.messages.map {|x| message_json(x)}, status: 201
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
