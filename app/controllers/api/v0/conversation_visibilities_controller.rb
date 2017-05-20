module Api
  module V0
    class ConversationVisibilitiesController < Api::V0::BaseController
      before_action only: %i(destroy) do
        require_access_token %w(read write)
      end

      rescue_from ActiveRecord::RecordNotFound do 
        render json: {error: I18n.t("conversations.not_found")}, status: 404
      end

      def destroy
        vis = conversation_service.get_visibility(params[:conversation_id])
        participants = vis.conversation.participants.count
        vis.destroy!
        if participants == 1
          render json: { 
            message: I18n.t('conversations.destroy.delete_success') 
          }
        else
          render json: { 
            message: I18n.t('conversations.destroy.hide_success') 
          }
        end
      end

      def conversation_service
        ConversationService.new(current_user)
      end

    end
  end
end
