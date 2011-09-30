#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html, :mobile, :json

  def create
    positive = (params[:positive] == 'true') ? true : false
    if target
      @like = current_user.build_like(:positive => positive, :target => target)

      if @like.save
        Rails.logger.info("event=create type=like user=#{current_user.diaspora_handle} status=success like=#{@like.id} positive=#{positive}")
        Postzord::Dispatcher.build(current_user, @like).post

        respond_to do |format|
          format.js { render 'likes/update', :status => 201 }
          format.html { render :nothing => true, :status => 201 }
          format.mobile { redirect_to post_path(@like.post_id) }
          format.json { render :nothing => true, :status => 201 }
        end
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    if @like = Like.where(:id => params[:id], :author_id => current_user.person.id).first
      current_user.retract(@like)
      respond_to do |format|
        format.any { }
        format.js { render 'likes/update' }
        format.json { render :nothing => true, :status => :ok}
      end
    else
      respond_to do |format|
        format.mobile { redirect_to :back }
        format.js { render :nothing => true, :status => 403 }
        format.json { render :nothing => true, :status => 403}
      end
    end
  end

  def index
    if target
      @likes = target.likes.includes(:author => :profile)
      render :layout => false
    else
      render :nothing => true, :status => 404
    end
  end

  def target
    @target ||= if params[:post_id]
      current_user.find_visible_post_by_id(params[:post_id])
    else
      comment = Comment.find(params[:comment_id])
      comment = nil unless current_user.find_visible_post_by_id(comment.post_id)
      comment
    end
  end
end
