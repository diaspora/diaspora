#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    target = current_user.find_visible_post_by_id params[:comment][:post_id]
    text = params[:comment][:text]

    @comment = current_user.comment(text, :on => target) if target
    if @comment
      render :nothing => true, :status => 201
    else
      render :nothing => true, :status => 401
    end
  end

end
