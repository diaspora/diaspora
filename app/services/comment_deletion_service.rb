class CommentDeletionService
  def initialize(params)
    @user = params[:user]
    comment_id = params[:comment_id]
    @comment = Comment.find(comment_id)
  end

  def destroy_comment
    if @user.owns?(@comment) || @user.owns?(@comment.parent)
      @user.retract(@comment)
      true
    else
      false
    end
  end
end
