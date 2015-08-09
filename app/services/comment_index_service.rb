class CommentIndexService
  attr_reader :post, :comments

  def initialize(params)
    @user = params[:user]
    @post_id = params[:post_id]
    @post = find_post!
    @comments = @post.comments.for_a_stream
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
