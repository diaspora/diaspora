# frozen_string_literal: true

module Notifications
  class LikedCommentService
    def self.notify(like, _)
      actor = like.author
      target_author = like.target.author

      return unless like.target_type == "Comment" && target_author.local? && actor != target_author

      recipient = target_author.owner
      Notifications::LikedComment
        .concatenate_or_create(recipient, like.target, actor)

      NotificationService.new(recipient).mail(
        Mail::LikedCommentWorker,
        recipient.id,
        actor.id,
        like.id
      )
    end
  end
end
