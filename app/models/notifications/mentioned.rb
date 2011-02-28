class Notifications::Mentioned < Notification
  def mail_job
    Job::MailMentioned
  end
end
