#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::Mentioned < Notification
  def mail_job
    Jobs::Mailers::Mentioned
  end
  
  def popup_translation_key
    'notifications.mentioned'
  end

  def deleted_translation_key
    'notifications.mentioned_deleted'
  end

  def linked_object
    Mention.find(self.target_id).post
  end
end
