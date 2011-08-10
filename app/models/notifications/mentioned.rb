class Notifications::Mentioned < Notification
  def mail_job
    Job::Mail::Mentioned
  end
  def popup_translation_key
    'notifications.mentioned'
  end
end
