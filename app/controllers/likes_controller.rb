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
    like = like_service.create(params[:post_id])
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render text: I18n.t("likes.create.error"), status: 422
  else
    respond_to do |format|
      format.html { render nothing: true, status: 201 }
      format.mobile { redirect_to post_path(like.post_id) }
      format.json { render json: like.as_api_response(:backbone), status: 201 }
    end
  end

  def destroy
    if like_service.destroy(params[:id])
      render nothing: true, status: 204
    else
      render text: I18n.t("likes.destroy.error"), status: 404
    end
  end

  def index
    render json: like_service.find_for_post(params[:post_id])
      .includes(author: :profile)
      .as_api_response(:backbone)
  end

  private

  def like_service
    @like_service ||= LikeService.new(current_user)
  end
end
