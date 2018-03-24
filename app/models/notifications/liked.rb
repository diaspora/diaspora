# frozen_string_literal: true

module Notifications
  class Liked < Notification
    def mail_job
      Workers::Mail::Liked
    end

    def popup_translation_key
      "notifications.liked"
    end

    def deleted_translation_key
      "notifications.liked_post_deleted"
    end

    def self.notify(like, _recipient_user_ids)
      actor = like.author
      target_author = like.target.author

      return unless like.target_type == "Post" && target_author.local? && actor != target_author

      concatenate_or_create(target_author.owner, like.target, actor).email_the_user(like, actor)
    end
  end
end
