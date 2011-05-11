class Notifications::CommentOnPost < Notification
  def mail_job
    Job::MailCommentOnPost
  end
  def popup_translation_key
    'notifications.comment_on_post'
  end
end
