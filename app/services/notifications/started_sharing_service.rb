# frozen_string_literal: true

module Notifications
  class StartedSharingService
    def self.notify(contact, _)
      sender = contact.person
      Notifications::StartedSharing
        .create_notification(contact.user, sender, sender)
        .try(:email_the_user, sender, sender)
    end
  end
end
