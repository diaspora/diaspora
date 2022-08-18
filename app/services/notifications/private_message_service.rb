# frozen_string_literal: true

module Notifications
  class PrivateMessageService
    def self.notify(object, _)
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
        Notifications::PrivateMessage
          .new(recipient: recipient)

        recipient.mail(
          Workers::Mail::PrivateMessage,
          recipient.id,
          message.author.id,
          message.id
        )
      end
    end
  end
end
