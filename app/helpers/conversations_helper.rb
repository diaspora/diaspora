module ConversationsHelper
  def conversation_class(conversation, unread_count, selected_conversation_id)
    conv_class = unread_count > 0 ? "unread " : ""
    if selected_conversation_id && conversation.id == selected_conversation_id
      conv_class << "selected"
    end
    conv_class
  end
end
