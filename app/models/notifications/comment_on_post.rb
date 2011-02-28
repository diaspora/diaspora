class Notifications::CommentOnPost < Notification
  def mail_job
    Job::MailCommentOnPost
  end
end
