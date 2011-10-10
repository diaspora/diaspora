#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::Liked < Notification
  def mail_job
    Jobs::Mailers::Liked
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
