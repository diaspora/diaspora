class Notifications::Mentioned < Notification
  def mail_job
    Workers::Mail::Mentioned
  end
  
  def popup_translation_key
    'notifications.mentioned'
  end

  def deleted_translation_key
    'notifications.mentioned_deleted'
  end

  def linked_object
    Mention.find(self.target_id).post
  end
end
