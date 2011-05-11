class Notifications::NewRequest < Notification
  def mail_job
    Job::MailRequestReceived
  end
  def popup_translation_key
    'notifications.new_request'
  end
end
