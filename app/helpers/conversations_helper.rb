module ConversationsHelper
  def new_message_text(count)
    if count > 0
      t('new_messages', :count => count)
    else
      t('no_new_messages')
    end
  end
end
