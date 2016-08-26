module Notifications
  class AlsoCommented < Notification
    def mail_job
      Workers::Mail::AlsoCommented
    end

    def popup_translation_key
      "notifications.also_commented"
    end

    def deleted_translation_key
      "notifications.also_commented_deleted"
    end

    def self.notify(comment, _recipient_user_ids)
      actor = comment.author
      commentable = comment.commentable
      recipient_ids = commentable.participants.local.where.not(id: [commentable.author_id, actor.id]).pluck(:owner_id)

      User.where(id: recipient_ids).find_each do |recipient|
        next if recipient.is_shareable_hidden?(commentable)

        concatenate_or_create(recipient, commentable, actor).try(:email_the_user, comment, actor)
      end
    end
  end
end
