class CommentService
  def initialize(user=nil)
    @user = user
  end

  def create(post_id, text)
    post = post_service.find!(post_id)
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
    post_service.find!(post_id).comments.for_a_stream
  end

  private

  attr_reader :user

  def post_service
    @post_service ||= PostService.new(user)
  end
end
