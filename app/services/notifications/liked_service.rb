# frozen_string_literal: true

module Notifications
  class LikedService
    def self.notify(like, _)
      actor = like.author
      target_author = like.target.author

      return unless like.target_type == "Post" && target_author.local? && actor != target_author

      recipient = target_author.owner
      Notifications::Liked
        .concatenate_or_create(recipient, like.target, actor)

      recipient.mail(
        Workers::Mail::Liked,
        recipient.id,
        actor.id,
        like.id
      )
    end
  end
end
