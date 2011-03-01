class Notifications::AlsoCommented < Notification
  def mail_job
    Job::MailAlsoCommented
  end
  def translation_key
    'also_commented'
  end
end
