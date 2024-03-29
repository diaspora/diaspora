# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!, except: :index

  respond_to :html,
             :mobile,
             :json

  rescue_from Diaspora::NonPublic do
    authenticate_user!
  end

  def index
    like = if params[:post_id]
             like_service.find_for_post(params[:post_id])
           else
             like_service.find_for_comment(params[:comment_id])
           end
    render json: like
      .includes(author: :profile)
      .as_api_response(:backbone)
  end

  def create
    like = if params[:post_id]
             like_service.create_for_post(params[:post_id])
           else
             like_service.create_for_comment(params[:comment_id])
           end
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render plain: I18n.t("likes.create.error"), status: 422
  else
    respond_to do |format|
      format.html { head :created }
      format.mobile { redirect_to post_path(like.post_id) }
      format.json { render json: like.as_api_response(:backbone), status: 201 }
    end
  end

  def destroy
    if like_service.destroy(params[:id])
      head :no_content
    else
      render plain: I18n.t("likes.destroy.error"), status: 404
    end
  end

  private

  def like_service
    @like_service ||= LikeService.new(current_user)
  end
end
