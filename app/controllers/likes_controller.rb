#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!

  respond_to :html,
             :mobile,
             :json

  def create
    @like = current_user.like!(target) if target rescue ActiveRecord::RecordInvalid

    if @like
      respond_to do |format|
        format.html { render :nothing => true, :status => 201 }
        format.mobile { redirect_to post_path(@like.post_id) }
        format.json { render :json => @like.as_api_response(:backbone), :status => 201 }
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    @like = Like.find_by_id_and_author_id!(params[:id], current_user.person.id)

    current_user.retract(@like)
    respond_to do |format|
      format.json { render :nothing => true, :status => 204 }
    end
  end

  #I can go when the old stream goes.
  def index
    @likes = target.likes.includes(:author => :profile)
    @people = @likes.map(&:author)

    respond_to do |format|
      format.all { render :layout => false }
      format.json { render :json => @likes.as_api_response(:backbone) }
    end
  end

  private

  def target
    @target ||= if params[:post_id]
      current_user.find_visible_shareable_by_id(Post, params[:post_id]) || raise(ActiveRecord::RecordNotFound.new)
    else
      Comment.find(params[:comment_id]).tap do |comment|
       raise(ActiveRecord::RecordNotFound.new) unless current_user.find_visible_shareable_by_id(Post, comment.commentable_id)
      end
    end
  end
end
