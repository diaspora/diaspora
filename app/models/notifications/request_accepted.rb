class Notifications::RequestAccepted < Notification
  def mail_job
    Job::Mail::RequestAcceptance
  end
  def popup_translation_key
    'notifications.request_accepted'
  end
end
