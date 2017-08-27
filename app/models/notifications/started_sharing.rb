# frozen_string_literal: true

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
      create_notification(contact.user, sender, sender).try(:email_the_user, sender, sender)
    end

    def contact
      recipient.contact_for(target)
    end
  end
end
