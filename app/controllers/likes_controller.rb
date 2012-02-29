#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("app", "presenters", "post_presenter")

class LikesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html,
             :mobile,
             :json

  def create
    @like = current_user.like!(target) if target

    if @like
      respond_to do |format|
        format.html { render :nothing => true, :status => 201 }
        format.mobile { redirect_to post_path(@like.post_id) }
        format.json { render :json => find_json_for_like, :status => 201 }
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    @like = Like.where(:id => params[:id], :author_id => current_user.person.id).first

    if @like
      current_user.retract(@like)
      respond_to do |format|
        format.json { render :json => find_json_for_like, :status => 202 }
      end
    else
      respond_to do |format|
        format.mobile { redirect_to :back }
        format.json { render :nothing => true, :status => 403}
      end
    end
  end

  def index
    if target
      @likes = target.likes.includes(:author => :profile)
      @people = @likes.map(&:author)

      respond_to do |format|
        format.all{ render :layout => false }
        format.json{ render :json => @likes.as_api_response(:backbone) }
      end
    else
      render :nothing => true, :status => 404
    end
  end

  protected

  def target
    @target ||= if params[:post_id]
      current_user.find_visible_shareable_by_id(Post, params[:post_id])
    else
      comment = Comment.find(params[:comment_id])
      comment = nil unless current_user.find_visible_shareable_by_id(Post, comment.commentable_id)
      comment
    end
  end

  def find_json_for_like
    if @like.parent.is_a? Post
      PostPresenter.new(@like.parent, current_user).to_json
    else
      @like.parent.as_api_response(:backbone)
    end
  end
end
