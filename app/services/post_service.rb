class PostService
  def initialize(user=nil)
    @user = user
  end

  def find(id_or_guid)
    if user
      find_non_public_by_guid_or_id_with_user(id_or_guid)
    else
      find_public(id_or_guid)
    end
  end

  def mark_user_notifications(post_id)
    return unless user
    mark_comment_reshare_like_notifications_read(post_id)
    mark_mention_notifications_read(post_id)
  end

  def destroy(post_id)
    post = find(post_id)
    raise Diaspora::NotMine unless post.author == user.person
    user.retract(post)
  end

  private

  attr_reader :user

  def find_public(id_or_guid)
    Post.where(post_key(id_or_guid) => id_or_guid).first.tap do |post|
      raise ActiveRecord::RecordNotFound, "could not find a post with id #{id_or_guid}" unless post
      raise Diaspora::NonPublic unless post.public?
    end
  end

  def find_non_public_by_guid_or_id_with_user(id_or_guid)
    user.find_visible_shareable_by_id(Post, id_or_guid, key: post_key(id_or_guid)).tap do |post|
      raise ActiveRecord::RecordNotFound, "could not find a post with id #{id_or_guid} for user #{user.id}" unless post
    end
  end

  # We can assume a guid is at least 16 characters long as we have guids set to hex(8) since we started using them.
  def post_key(id_or_guid)
    id_or_guid.to_s.length < 16 ? :id : :guid
  end

  def mark_comment_reshare_like_notifications_read(post_id)
    notifications = Notification.where(recipient_id: user.id, target_type: "Post", target_id: post_id, unread: true)
    notifications.each do |notification|
      notification.set_read_state(true)
    end
  end

  def mark_mention_notifications_read(post_id)
    mention = find(post_id).mentions.where(person_id: user.person_id).first
    Notification.where(recipient_id: user.id, target_type: "Mention", target_id: mention.id, unread: true)
      .first.try(:set_read_state, true) if mention
  end
end
