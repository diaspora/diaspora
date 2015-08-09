class CommentCreationService
  def initialize(params)
    @user = params[:user]
    @post_id = params[:post_id]
    @text = params[:text]
  end

  def create_comment
    post = @user.find_visible_shareable_by_id(Post, @post_id)
    @user.comment!(post, @text) if post
  end
end
