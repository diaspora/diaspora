#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::StartedSharing < Notification
  def mail_job
    Jobs::Mailers::StartedSharing
  end

  def popup_translation_key
    'notifications.started_sharing'
  end

  def email_the_user(target, actor)
    super(target.sender, actor)
  end

  private

  def self.make_notification(recipient, target, actor, notification_type)
    super(recipient, target.sender, actor, notification_type)
  end

end
