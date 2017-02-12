module Notifications
  class Mentioned < Notification
    def mail_job
      Workers::Mail::Mentioned
    end

    def popup_translation_key
      "notifications.mentioned"
    end

    def deleted_translation_key
      "notifications.mentioned_deleted"
    end

    def linked_object
      target.post
    end

    def self.notify(mentionable, recipient_user_ids)
      actor = mentionable.author

      mentionable.mentions.select {|mention| mention.person.local? }.each do |mention|
        recipient = mention.person

        next if recipient == actor || !(mentionable.public || recipient_user_ids.include?(recipient.owner_id))

        create_notification(recipient.owner, mention, actor).try(:email_the_user, mention, actor)
      end
    end
  end
end
