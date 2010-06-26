class CommentsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    target = Post.first(:id => params[:comment][:post_id])
    text = params[:comment][:text]
    if current_user.comment text, :on => target
      render :text => "Woo!"
    else
      render :text => "Boo!"
    end
  end

end