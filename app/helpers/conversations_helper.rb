# frozen_string_literal: true

module ConversationsHelper
  def conversation_class(conversation, unread_count, selected_conversation_id)
    conv_class = unread_count > 0 ? "unread" : ""
    return conv_class unless selected_conversation_id && conversation.id == selected_conversation_id

    "#{conv_class} selected"
  end
end
