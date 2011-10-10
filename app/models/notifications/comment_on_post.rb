#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::CommentOnPost < Notification
  def mail_job
    Jobs::Mailers::CommentOnPost
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
