class Notifications::StartedSharing < Notification
  def mail_job
    Job::MailStartedSharing
  end
  def translation_key
    'started_sharing'
  end
end
