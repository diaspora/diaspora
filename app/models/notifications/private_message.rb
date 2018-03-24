# frozen_string_literal: true

module Notifications
  class PrivateMessage < Notification
    def mail_job
      Workers::Mail::PrivateMessage
    end

    def popup_translation_key
      "notifications.private_message"
    end

    def self.notify(object, _recipient_user_ids)
      case object
      when Conversation
        object.messages.each {|message| notify_message(message) }
      when Message
        notify_message(object)
      end
    end

    private_class_method def self.notify_message(message)
      recipient_ids = message.conversation.participants.local.where.not(id: message.author_id).pluck(:owner_id)
      User.where(id: recipient_ids).find_each do |recipient|
        message.increase_unread(recipient)
        new(recipient: recipient).email_the_user(message, message.author)
      end
    end
  end
end
