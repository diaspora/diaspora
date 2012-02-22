#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("app", "presenters", "post_presenter")

class ParticipationsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :mobile,
             :json

  def create
    @participation = current_user.participate!(target) if target

    if @participation
      respond_to do |format|
        format.mobile { redirect_to post_path(@participation.post_id) }
        format.json { render :json => PostPresenter.new(@participation.parent, current_user).to_json, :status => 201 }
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    @participation = Participation.where(:id => params[:id], :author_id => current_user.person.id).first

    if @participation
      current_user.retract(@participation)
      respond_to do |format|
        format.json { render :json => PostPresenter.new(@participation.parent, current_user).to_json, :status => 202 }
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
      @participations = target.participations.includes(:author => :profile)
      @people = @participations.map(&:author)

      respond_to do |format|
        format.all{ render :layout => false }
        format.json{ render :json => @participations.as_api_response(:backbone) }
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
end
