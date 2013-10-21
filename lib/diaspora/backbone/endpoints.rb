
module Diaspora::Backbone
  class Endpoints < Base

    get "/conversations" do
      authenticate!
      data = current_user.conversations.includes(participants: :profile)
      json(ConversationPresenter.as_collection(paginate(data), :full_hash))
    end

    post "/conversations" do
      authenticate!
      halt_400_bad_request unless params.has_key?('contact_ids') &&
                                  params['contact_ids'].is_a?(Array)

      begin
        opts = protected_params
                 .require(:conversation)
                 .permit( :subject, message: :text)
      rescue
        halt_400_bad_request
      end

      participant_ids = current_user.contacts.where(id: params['contact_ids']).pluck(:person_id)
      opts[:participant_ids] = participant_ids

      conversation = current_user.build_conversation(opts)
      halt_400_bad_request unless conversation.save

      current_user.dispatch!(conversation)
      json(ConversationPresenter.new(conversation))
    end

    delete "/conversations/:id/visibility" do
      authenticate!
      visibility = current_user.conversation_visibilities.where(conversation_visibilities: { conversation_id: params[:id] }).first
      halt_404_not_found unless visibility.present? && visibility.destroy

      200
    end

    get "/conversations/:id/messages" do
      authenticate!
      conversation = current_user.conversations.includes(messages: { author: :profile }, participants: :profile).where(id: params[:id]).first
      halt_404_not_found unless conversation.present?

      json(MessagePresenter.as_collection(paginate(conversation.messages), :full_hash))
    end

    post "/conversations/:id/messages" do
      authenticate!
      conversation = current_user.conversations.where(id: params[:id]).first
      halt_404_not_found unless conversation.present?

      begin
        opts = protected_params.require(:message).permit(:text)
      rescue
        halt_400_bad_request
      end

      message = current_user.build_message(conversation, opts)
      halt_400_bad_request unless message.save

      current_user.dispatch!(message)
      json(MessagePresenter.new(message))
    end
  end
end
