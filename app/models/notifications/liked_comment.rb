# frozen_string_literal: true

module Notifications
  class LikedComment < Notification
    def mail_job
      Workers::Mail::LikedComment
    end

    def popup_translation_key
      "notifications.liked_comment"
    end

    def deleted_translation_key
      "notifications.liked_comment_deleted"
    end

    def self.notify(like, _recipient_user_ids)
      actor = like.author
      target_author = like.target.author

      return unless like.target_type == "Comment" && target_author.local? && actor != target_author

      concatenate_or_create(target_author.owner, like.target, actor).email_the_user(like, actor)
    end
  end
end
