class Notifications::CommentOnPost < Notification
  def mail_job
    Job::MailCommentOnPost
  end
  def translation_key
    'comment_on_post'
  end
end
