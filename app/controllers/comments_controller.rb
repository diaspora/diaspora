#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class CommentsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html
  respond_to :json, :only => :show

  def create
    target = Post.find_by_id params[:comment][:post_id]
    text = params[:comment][:text]

    @comment = current_user.comment text, :on => target
    render :nothing => true
  end

  def show
    @comment = Comment.find_by_id params[:id]
    respond_with @comment
  end

end
