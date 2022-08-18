# frozen_string_literal: true

module Notifications
  class AlsoCommentedService
    def self.notify(comment, _)
      actor = comment.author
      commentable = comment.commentable
      recipient_ids = commentable.participants.local.where.not(id: [commentable.author_id, actor.id]).pluck(:owner_id)

      User.where(id: recipient_ids).find_each do |recipient|
        next if recipient.is_shareable_hidden?(commentable) || mention_notification_exists?(comment, recipient.person)

        Notifications::AlsoCommented
          .concatenate_or_create(recipient, commentable, actor)
          .try(:email_the_user, comment, actor)
      end
    end
  end
end
