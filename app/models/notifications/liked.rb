class Notifications::Liked < Notification
  def mail_job
    Job::MailLiked
  end
  def translation_key
    'liked'
  end
end
