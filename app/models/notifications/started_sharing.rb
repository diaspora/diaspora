class Notifications::StartedSharing < Notification
  def mail_job
    Job::MailStartedSharing
  end
  def translation_key
    'started_sharing'
  end

  def email_the_user(target, actor)
    super(target.sender, actor)
  end

  private

  def self.make_notification(recipient, target, actor, notification_type)
    super(recipient, target.sender, actor, notification_type)
  end

end
