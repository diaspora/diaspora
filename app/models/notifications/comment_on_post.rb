module Notifications
  class CommentOnPost < Notification
    def mail_job
      Workers::Mail::CommentOnPost
    end

    def popup_translation_key
      "notifications.comment_on_post"
    end

    def deleted_translation_key
      "notifications.also_commented_deleted"
    end

    def self.notify(comment, _recipient_user_ids)
      actor = comment.author
      commentable_author = comment.commentable.author

      return unless commentable_author.local? && actor != commentable_author

      concatenate_or_create(commentable_author.owner, comment.commentable, actor).email_the_user(comment, actor)
    end
  end
end
