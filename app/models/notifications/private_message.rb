class Notifications::PrivateMessage < Notification
  def mail_job
    Jobs::Mail::PrivateMessage
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
