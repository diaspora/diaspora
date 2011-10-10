#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::Reshared < Notification
  def mail_job
    Jobs::Mailers::Reshared
  end

  def popup_translation_key
    'notifications.reshared'
  end

  def deleted_translation_key
    'notifications.reshared_post_deleted'
  end

  def linked_object
    self.target
  end
end
