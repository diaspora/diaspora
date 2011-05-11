class Notifications::RequestAccepted < Notification
  def mail_job
    Job::MailRequestAcceptance
  end
  def popup_translation_key
    'notifications.request_accepted'
  end
end
