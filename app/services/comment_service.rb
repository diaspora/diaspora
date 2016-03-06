class CommentService
  def initialize(user=nil)
    @user = user
  end

  def create(post_id, text)
    post = find_post!(post_id)
    user.comment!(post, text)
  end

  def destroy(comment_id)
    comment = Comment.find(comment_id)
    if user.owns?(comment) || user.owns?(comment.parent)
      user.retract(comment)
      true
    else
      false
    end
  end

  def find_for_post(post_id)
    find_post!(post_id).comments.for_a_stream
  end

  private

  attr_reader :user

  def find_post!(post_id)
    find_post(post_id).tap do |post|
      raise ActiveRecord::RecordNotFound unless post
    end
  end

  def find_post(post_id)
    if user
      user.find_visible_shareable_by_id(Post, post_id)
    else
      Post.find_by_id_and_public(post_id, true)
    end
  end
end
