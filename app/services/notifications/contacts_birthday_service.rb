# frozen_string_literal: true

module Notifications
  class ContactsBirthdayService
    def self.notify(contact, _=nil)
      recipient = contact.user
      actor = contact.person
      create_notification(recipient, actor, actor).try(:email_the_user, actor, actor)
    end
  end
end
