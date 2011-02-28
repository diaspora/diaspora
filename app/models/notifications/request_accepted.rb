class Notifications::RequestAccepted < Notification
  def mail_job
    Job::MailRequestAcceptance
  end
end
