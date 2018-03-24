# frozen_string_literal: true

class NotificationService
  NOTIFICATION_TYPES = {
    Comment       => [Notifications::MentionedInComment, Notifications::CommentOnPost, Notifications::AlsoCommented],
    Like          => [Notifications::Liked],
    StatusMessage => [Notifications::MentionedInPost],
    Conversation  => [Notifications::PrivateMessage],
    Message       => [Notifications::PrivateMessage],
    Reshare       => [Notifications::Reshared],
    Contact       => [Notifications::StartedSharing]
  }.freeze

  def notify(object, recipient_user_ids)
    notification_types(object).each {|type| type.notify(object, recipient_user_ids) }
  end

  private

  def notification_types(object)
    NOTIFICATION_TYPES.fetch(object.class, [])
  end
end
