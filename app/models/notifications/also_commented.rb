class Notifications::AlsoCommented < Notification
  def mail_job
    Job::MailAlsoCommented
  end
end
