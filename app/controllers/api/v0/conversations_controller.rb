module Api
  module V0
    class ConversationsController < Api::V0::BaseController
      include ConversationsHelper

      before_action only: %i(create index show) do
        require_access_token %w(read)
      end

      before_action only: %i(create destroy) do
        require_access_token %w(read write)
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: {error: I18n.t("conversations.not_found")}, status: 404
      end

      def index
        conversations = conversation_service.all_for_user
        render json: conversations.map {|x| conversation_as_json(x) }
      end

      def show
        conversation = conversation_service.find!(params[:id])
        render json: {
          conversation: conversation_as_json(conversation)
        }
      end

      def create
        conversation = conversation_service.build(
          params[:subject],
          params[:text],
          params[:recipients]
        )
        conversation.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(
          current_user,
          conversation
        )

        render json: {
          conversation: conversation_as_json(conversation)
        }, status: 201
      end

      def destroy
        conversation_service.destroy!(params[:id])
        head :no_content
      end

      def conversation_service
        ConversationService.new(current_user)
      end

      def conversation_as_json(conversation)
        ConversationPresenter.new(conversation).as_json
      end
    end
  end
end
