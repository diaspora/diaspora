# frozen_string_literal: true

module Notifications
  class CommentOnPostService
    def self.notify(comment, _)
      actor = comment.author
      commentable_author = comment.commentable.author

      return unless commentable_author.local? && actor != commentable_author
      return if mention_notification_exists?(comment, commentable_author)

      recipient = commentable_author.owner
      Notifications::CommentOnPost
        .concatenate_or_create(recipient, comment.commentable, actor)

      NotificationService.new(recipient).mail(
        Workers::Mail::CommentOnPost,
        recipient.id,
        actor.id,
        comment.id
      )
    end
  end
end
