class Notifications::Mentioned < Notification
  def mail_job
    Job::MailMentioned
  end
  def translation_key
    'mentioned'
  end
end
