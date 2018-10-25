# frozen_string_literal: true

module Api
  module V1
    class ConversationsController < Api::V1::BaseController
      include ConversationsHelper

      before_action only: %i[create index show] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.conversations.not_found"), status: :not_found
      end

      def index
        params.permit(:only_after, :only_unread)
        mapped_params = {}
        mapped_params[:only_after] = params[:only_after] if params.has_key?(:only_after)

        mapped_params[:unread] = params[:only_unread] if params.has_key?(:only_unread)
        conversations = conversation_service.all_for_user(mapped_params)
        render json: conversations.map {|x| conversation_as_json(x) }
      end

      def show
        conversation = conversation_service.find!(params[:id])
        render json: conversation_as_json(conversation)
      end

      def create
        params.require(%i[subject body recipients])
        recipient_ids = JSON.parse(params[:recipients]).map {|p| Person.find_from_guid_or_username(id: p).id }
        conversation = conversation_service.build(
          params[:subject],
          params[:body],
          recipient_ids
        )
        raise ActiveRecord::RecordInvalid unless conversation.participants.length == (recipient_ids.length + 1)
        conversation.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(
          current_user,
          conversation
        )

        render json: conversation_as_json(conversation), status: :created
      rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::RecordNotFound
        render json: I18n.t("api.endpoint_errors.conversations.cant_process"), status: :unprocessable_entity
      end

      def destroy
        vis = conversation_service.get_visibility(params[:id])
        vis.destroy!
        head :no_content
      end

      def conversation_service
        ConversationService.new(current_user)
      end

      def conversation_as_json(conversation)
        ConversationPresenter.new(conversation).as_api_json
      end
    end
  end
end
