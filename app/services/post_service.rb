class PostService
  attr_reader :post

  def initialize(params)
    @id = params[:id]
    @user = params[:user]
    @oembed = params[:oembed]
  end

  def present_json
    PostPresenter.new(post, user)
  end

  def present_interactions_json
    PostInteractionPresenter.new(post, user)
  end

  def present_oembed
    OEmbedPresenter.new(post, oembed)
  end

  def assign_post_and_mark_notifications
    assign_post
    mark_corresponding_notifications_read if user
  end

  def assign_post
    if user
      @post = Post.find_non_public_by_guid_or_id_with_user(id, user)
    else
      @post = Post.find_public(id)
    end
  end

  def retract_post
    find_user_post
    user.retract(@post)
  end

  private

  attr_reader :user, :id, :oembed

  def find_user_post
    @post = user.posts.find(id)
  end

  def mark_corresponding_notifications_read
    mark_comment_reshare_like_notifications_read
    mark_mention_notifications_read
  end

  def mark_comment_reshare_like_notifications_read
    notification = Notification.where(recipient_id: user.id, target_type: "Post", target_id: post.id, unread: true)
    notification.each do |notification|
      notification.set_read_state(true)
    end
  end

  def mark_mention_notifications_read
    mention = post.mentions.where(person_id: user.person_id).first
    Notification.where(recipient_id: user.id, target_type: "Mention", target_id: mention.id, unread: true)
      .first.try(:set_read_state, true) if mention
  end
end
