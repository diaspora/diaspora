class Notifications::Mentioned < Notification
  def mail_job
    Job::MailMentioned
  end
  def popup_translation_key
    'notifications.mentioned'
  end
end
