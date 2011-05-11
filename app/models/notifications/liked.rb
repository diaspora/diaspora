class Notifications::Liked < Notification
  def mail_job
    Job::MailLiked
  end
  def popup_translation_key
    'notifications.liked'
  end
end
