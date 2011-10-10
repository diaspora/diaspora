#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::PrivateMessage < Notification
  def mail_job
    Jobs::Mailers::PrivateMessage
  end
  def popup_translation_key
    'notifications.private_message'
  end
  def self.make_notification(recipient, target, actor, notification_type)
    n = notification_type.new(:target => target,
                               :recipient_id => recipient.id)

    n.actors << actor
    n
  end
end
