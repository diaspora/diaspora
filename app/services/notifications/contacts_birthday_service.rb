# frozen_string_literal: true

module Notifications
  class ContactsBirthdayService
    def self.notify(contact, _=nil)
      recipient = contact.user
      actor = contact.person
      Notifications::ContactsBirthday
        .create_notification(recipient, actor, actor)

      recipient.mail(
        Workers::Mail::ContactsBirthday,
        recipient.id,
        actor.id,
        actor.id
      )
    end
  end
end
