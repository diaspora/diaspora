#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html, :mobile, :only => [:create, :destroy]
  respond_to :js, :only => [:index]

  rescue_from ActiveRecord::RecordNotFound do
    render :nothing => true, :status => 404
  end

  def create
    target = current_user.find_visible_post_by_id params[:post_id]
    text = params[:text]

    if target
      @comment = current_user.build_comment(:text => text, :post => target)

      if @comment.save
        Rails.logger.info(:event => :create, :type => :comment, :user => current_user.diaspora_handle,
                          :status => :success, :comment => @comment.id, :chars => params[:text].length)
        Postzord::Dispatch.new(current_user, @comment).post

        respond_to do |format|
          format.js{ render(:create, :status => 201)}
          format.html{ render :nothing => true, :status => 201 }
          format.mobile{ redirect_to post_url(@comment.post) }
        end
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if current_user.owns?(@comment) || current_user.owns?(@comment.parent)
      current_user.retract(@comment)
      respond_to do |format|
        format.mobile{ redirect_to @comment.post }
        format.js {render :nothing => true, :status => 204}
      end
    else
      respond_to do |format|
        format.mobile {redirect_to :back}
        format.js {render :nothing => true, :status => 403}
      end
    end
  end

  def index
    @post = current_user.find_visible_post_by_id(params[:post_id])
    if @post
      @comments = @post.comments.includes(:author => :profile)
      render :layout => false
    else
      raise ActiveRecord::RecordNotFound.new
    end
  end

end
