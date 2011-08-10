class Notifications::Liked < Notification
  def mail_job
    Job::Mail::Liked
  end
  def popup_translation_key
    'notifications.liked'
  end
end
