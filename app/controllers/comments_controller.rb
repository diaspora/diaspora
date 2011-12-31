#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :except => [:index]

  respond_to :html, :mobile, :except => :show
  respond_to :js, :only => [:index]

  rescue_from ActiveRecord::RecordNotFound do
    render :nothing => true, :status => 404
  end

  def create
    target = current_user.find_visible_shareable_by_id Post, params[:post_id]
    text = params[:text]

    if target
      @comment = current_user.build_comment(:text => text, :post => target)

      if @comment.save
        Rails.logger.info("event => :create, :type => :comment, :user => #{current_user.diaspora_handle},
                          :status => :success, :comment => #{@comment.id}, :chars => #{params[:text].length}")
        Postzord::Dispatcher.build(current_user, @comment).post

        respond_to do |format|
          format.js{ render(:create, :status => 201)}
          format.html{ render :nothing => true, :status => 201 }
          format.mobile{ render :partial => 'comment', :locals => {:post => @comment.post, :comment => @comment} }
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
        format.js { render :nothing => true, :status => 204 }
        format.mobile{ redirect_to @comment.post }
      end
    else
      respond_to do |format|
        format.mobile {redirect_to :back}
        format.js {render :nothing => true, :status => 403}
      end
    end
  end

  def index
    if user_signed_in?
      @post = current_user.find_visible_shareable_by_id(Post, params[:post_id])
    else
      @post = Post.where(:id => params[:post_id], :public => true).includes(:author, :comments => :author).first
    end

    if @post
      @comments = @post.comments.includes(:author => :profile).order('created_at ASC')
      render :layout => false
    else
      raise ActiveRecord::RecordNotFound.new
    end
  end

  def new
    render :layout => false
  end
end
