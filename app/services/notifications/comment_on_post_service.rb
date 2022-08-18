# frozen_string_literal: true

module Notifications
  class CommentOnPostService
    def self.notify(comment, _)
      actor = comment.author
      commentable_author = comment.commentable.author

      return unless commentable_author.local? && actor != commentable_author
      return if mention_notification_exists?(comment, commentable_author)

      Notifications::CommentOnPost
        .concatenate_or_create(commentable_author.owner, comment.commentable, actor)
        .email_the_user(comment, actor)
    end
  end
end
