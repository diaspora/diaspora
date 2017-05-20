module Api
  module V0
    class MessagesController < Api::V0::BaseController
      before_action only: %i(create) do
        require_access_token %w(read write)
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: {error: I18n.t("conversations.not_found")}, status: 404
      end

      def create
        conversation = conversation_service.find!(params[:conversation_id])
        opts = params.require(:message).permit(:text)
        message = current_user.build_message(conversation, opts)
        message.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(current_user, message)
        render json: message, status: 201
      end

      def conversation_service
        ConversationService.new(current_user)
      end
    end
  end
end
