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

  NOTIFICATIONS_JSON_TYPES = {
    "also_commented"       => "Notifications::AlsoCommented",
    "comment_on_post"      => "Notifications::CommentOnPost",
    "liked"                => "Notifications::Liked",
    "mentioned"            => "Notifications::MentionedInPost",
    "mentioned_in_comment" => "Notifications::MentionedInComment",
    "reshared"             => "Notifications::Reshared",
    "started_sharing"      => "Notifications::StartedSharing",
    "contacts_birthday"    => "Notifications::ContactsBirthday"
  }.freeze

  NOTIFICATIONS_REVERSE_JSON_TYPES = NOTIFICATIONS_JSON_TYPES.invert.freeze

  def initialize(user=nil)
    @user = user
  end

  def index(unread_only=nil, only_after=nil)
    query_string = "recipient_id = ? "
    query_string += "AND unread = true " if unread_only
    where_clause = [query_string, @user.id]
    if only_after
      query_string += " AND created_at >= ?"
      where_clause = [query_string, @user.id, only_after]
    end
    Notification.where(where_clause).includes(:target, actors: :profile)
  end

  def get_by_guid(guid)
    Notification.where(recipient_id: @user.id, guid: guid).first
  end

  def update_status_by_guid(guid, is_read_status)
    notification = get_by_guid(guid)
    raise ActiveRecord::RecordNotFound unless notification

    notification.set_read_state(is_read_status)
    true
  end

  def notify(object, recipient_user_ids)
    notification_types(object).each {|type| type.notify(object, recipient_user_ids) }
  end

  private

  def notification_types(object)
    NOTIFICATION_TYPES.fetch(object.class, [])
  end
end
