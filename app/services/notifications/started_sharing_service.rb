# frozen_string_literal: true

module Notifications
  class StartedSharingService
    def self.notify(contact, _)
      sender = contact.person
      recipient = contact.user
      Notifications::StartedSharing
        .create_notification(recipient, sender, sender)

      NotificationService.new(recipient).mail(
        Workers::Mail::StartedSharing,
        recipient.id,
        sender.id,
        sender.id
      )
    end
  end
end
