#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    target = current_user.find_visible_post_by_id params[:comment][:post_id]
    text = params[:comment][:text]

    @comment = current_user.comment(text, :on => target) if target
    if @comment
      Rails.logger.info("event=comment_create user=#{current_user.diaspora_handle} status=success comment=#{@comment.inspect}")

      respond_to do |format|
        format.js{ render :json => { :post_id => @comment.post_id,
                                     :comment_id => @comment.id,
                                     :html => render_to_string(:partial => type_partial(@comment), :locals => {:comment => @comment, :person => current_user, :current_user => current_user})},
                                     :status => 201 }
        format.html{ render :nothing => true, :status => 201 }
      end
    else
      render :nothing => true, :status => 406
    end
  end

end
