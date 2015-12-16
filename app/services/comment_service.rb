class CommentService
  attr_reader :post, :comments

  def initialize(params)
    @user = params[:user]
    @post_id = params[:post_id]
    @comment_id = params[:comment_id]
    @text = params[:text]

    @post = find_post! if @post_id
    @comments = @post.comments.for_a_stream if @post
  end

  def create_comment
    @user.comment!(post, @text) if @post
  end

  def destroy_comment
    @comment = Comment.find(@comment_id)
    if @user.owns?(@comment) || @user.owns?(@comment.parent)
      @user.retract(@comment)
      true
    else
      false
    end
  end

  private

  def find_post!
    find_post.tap do |post|
      raise(ActiveRecord::RecordNotFound) unless post
    end
  end

  def find_post
    if @user
      @user.find_visible_shareable_by_id(Post, @post_id)
    else
      Post.find_by_id_and_public(@post_id, true)
    end
  end
end
