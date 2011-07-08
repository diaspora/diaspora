#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html, :mobile, :json

  def create
    if params[:post_id]
      target = current_user.find_visible_post_by_id params[:post_id]
    else
      target = Comment.find(params[:comment_id])
    end

    positive = (params[:positive] == 'true') ? true : false
    if target
      @like = current_user.build_like(:positive => positive, :target => target)

      if @like.save
        Rails.logger.info("event=create type=like user=#{current_user.diaspora_handle} status=success like=#{@like.id} positive=#{positive}")
        Postzord::Dispatch.new(current_user, @like).post

        respond_to do |format|
          format.js { render :status => 201 }
          format.html { render :nothing => true, :status => 201 }
          format.mobile { redirect_to post_path(@like.post_id) }
        end
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    target_id = params[:post_id] || params[:comment_id]

    if @like = Like.where(:id => params[:id], :author_id => current_user.person.id, :target_id => target_id).first
      current_user.retract(@like)
    else
      respond_to do |format|
        format.mobile {redirect_to :back}
        format.js {render :nothing => true, :status => 403}
      end
    end
  end

  def index
    if target = current_user.find_visible_post_by_id(params[:post_id])
      @likes = target.likes.includes(:author => :profile)
      render :layout => false
    else
      render :nothing => true, :status => 404
    end
  end
end
