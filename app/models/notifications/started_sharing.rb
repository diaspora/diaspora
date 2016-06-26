module Notifications
  class StartedSharing < Notification
    def mail_job
      Workers::Mail::StartedSharing
    end

    def popup_translation_key
      "notifications.started_sharing"
    end

    def self.notify(contact, _recipient_user_ids)
      sender = contact.person
      create_notification(contact.user_id, sender, sender).email_the_user(sender, sender)
    end
  end
end
