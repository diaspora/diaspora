# frozen_string_literal: true

module Notifications
  class MentionedInComment < Notification
    include Notifications::Mentioned

    def popup_translation_key
      "notifications.mentioned_in_comment"
    end

    def deleted_translation_key
      "notifications.mentioned_in_comment_deleted"
    end

    def self.filter_mentions(mentions, mentionable, _recipient_user_ids)
      mentions.includes(:person).merge(Person.allowed_to_be_mentioned_in_a_comment_to(mentionable.parent))
    end

    def mail_job
      if !recipient.user_preferences.exists?(email_type: "mentioned_in_comment")
        Workers::Mail::MentionedInComment
      elsif shareable.author.owner_id == recipient_id
        Workers::Mail::CommentOnPost
      elsif shareable.participants.local.where(owner_id: recipient_id)
        Workers::Mail::AlsoCommented
      end
    end

    private

    def shareable
      linked_object.parent
    end
  end
end
