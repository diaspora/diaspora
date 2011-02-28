class Notifications::NewRequest < Notification
  def mail_job
    Job::MailRequestReceived
  end
end
