class Notifications::Liked < Notification
  def mail_job
    Workers::Mail::Liked
  end
  
  def popup_translation_key
    'notifications.liked'
  end

  def deleted_translation_key
    'notifications.liked_post_deleted'
  end
  
  def linked_object
    post = self.target
    post = post.target if post.is_a? Like
    post
  end
end
