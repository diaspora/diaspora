# frozen_string_literal: true

module Notifications
  class ContactsBirthday < Notification
    def mail_job
      Workers::Mail::ContactsBirthday
    end

    def popup_translation_key
      "notifications.contacts_birthday"
    end

    def self.notify(contact, _recipient_user_ids)
      recipient = contact.user
      actor = contact.person
      create_notification(recipient, actor, actor).try(:email_the_user, actor, actor)
    end
  end
end
