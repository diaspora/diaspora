# frozen_string_literal: true

module Notifications
  class MentionedInPost < Notification
    include Notifications::Mentioned

    def mail_job
      Workers::Mail::Mentioned
    end

    def popup_translation_key
      "notifications.mentioned"
    end

    def deleted_translation_key
      "notifications.mentioned_deleted"
    end

    def self.filter_mentions(mentions, mentionable, recipient_user_ids)
      return mentions if mentionable.public
      mentions.where(person: Person.where(owner_id: recipient_user_ids).ids)
    end
  end
end
