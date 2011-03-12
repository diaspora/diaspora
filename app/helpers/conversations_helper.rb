module ConversationsHelper
  def new_message_text(count)
    t('conversations.helper.new_messages', :count => count)
  end
end
