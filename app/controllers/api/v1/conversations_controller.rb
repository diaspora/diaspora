# frozen_string_literal: true

module Api
  module V1
    class ConversationsController < Api::V1::BaseController
      include ConversationsHelper

      BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

      before_action do
        require_access_token %w[conversations]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "Conversation with provided guid could not be found"
      end

      def index
        mapped_params = {}
        mapped_params[:only_after] = params[:only_after] if params.has_key?(:only_after)

        mapped_params[:unread] = BOOLEAN_TYPE.cast(params[:only_unread]) if params.has_key?(:only_unread)

        conversations_query = conversation_service.all_for_user(mapped_params)
        conversations_page = pager(conversations_query, "conversations.created_at").response
        conversations_page[:data] = conversations_page[:data].map {|x| conversation_as_json(x) }
        render_paged_api_response conversations_page
      end

      def show
        conversation = conversation_service.find!(params[:id])
        render json: conversation_as_json(conversation)
      end

      def create
        params.require(%i[subject body recipients])
        recipients = recipient_ids
        conversation = conversation_service.build(params[:subject], params[:body], recipients)
        raise ActiveRecord::RecordInvalid unless conversation_valid?(conversation, recipients)

        conversation.save!
        Diaspora::Federation::Dispatcher.defer_dispatch(current_user, conversation)
        render json: conversation_as_json(conversation), status: :created
      rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::RecordNotFound
        render_error 422, "Couldn’t accept or process the conversation"
      end

      def destroy
        conversation = conversation_service.get_visibility(params[:id])
        conversation.destroy!
        head :no_content
      end

      private

      def conversation_service
        @conversation_service ||= ConversationService.new(current_user)
      end

      def conversation_as_json(conversation)
        ConversationPresenter.new(conversation, current_user).as_api_json
      end

      def pager(query, sort_field)
        Api::Paging::RestPaginatorBuilder.new(query, request).time_pager(params, sort_field)
      end

      def recipient_ids
        params[:recipients].map {|p| Person.find_from_guid_or_username(id: p).id }
      end

      def conversation_valid?(conversation, recipients)
        conversation.participants.length == (recipients.length + 1)
      end
    end
  end
end
