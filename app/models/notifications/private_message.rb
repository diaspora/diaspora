module Notifications
  class PrivateMessage < Notification
    def mail_job
      Workers::Mail::PrivateMessage
    end

    def popup_translation_key
      "notifications.private_message"
    end

    def self.notify(object, recipient_user_ids)
      case object
      when Conversation
        object.messages.each do |message|
          recipient_ids = recipient_user_ids - [message.author.owner_id]
          User.where(id: recipient_ids).find_each {|recipient| notify_message(message, recipient) }
        end
      when Message
        recipients = object.conversation.participants.select(&:local?) - [object.author]
        recipients.each {|recipient| notify_message(object, recipient.owner) }
      end
    end

    def self.notify_message(message, recipient)
      message.increase_unread(recipient)
      new(recipient: recipient).email_the_user(message, message.author)
    end
    private_class_method :notify_message
  end
end
