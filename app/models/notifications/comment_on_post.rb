class Notifications::CommentOnPost < Notification
  def mail_job
    Workers::Mail::CommentOnPost
  end

  def popup_translation_key
    'notifications.comment_on_post'
  end

  def deleted_translation_key
    'notifications.also_commented_deleted'
  end

  def linked_object
    Post.where(:id => self.target_id).first
  end
end
