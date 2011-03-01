class Notifications::RequestAccepted < Notification
  def mail_job
    Job::MailRequestAcceptance
  end
  def translation_key
    'request_accepted'
  end
end
