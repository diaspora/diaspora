# frozen_string_literal: true

module Notifications
  class CommentOnPost < Notification
    include Notifications::Commented

    def mail_job
      Workers::Mail::CommentOnPost
    end

    def popup_translation_key
      "notifications.comment_on_post"
    end

    def self.notify(comment, _recipient_user_ids)
      actor = comment.author
      commentable_author = comment.commentable.author

      return unless commentable_author.local? && actor != commentable_author
      return if mention_notification_exists?(comment, commentable_author)

      concatenate_or_create(commentable_author.owner, comment.commentable, actor).email_the_user(comment, actor)
    end
  end
end
