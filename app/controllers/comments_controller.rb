#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  before_action :authenticate_user!, except: :index

  respond_to :html, :mobile, :json

  rescue_from ActiveRecord::RecordNotFound do
    render nothing: true, status: 404
  end

  def create
    begin
      comment = comment_service.create(params[:post_id], params[:text])
    rescue ActiveRecord::RecordNotFound
      render text: I18n.t("comments.create.error"), status: 404
      return
    end

    if comment
      respond_create_success(comment)
    else
      render text: I18n.t("comments.create.error"), status: 422
    end
  end

  def destroy
    if comment_service.destroy(params[:id])
      respond_destroy_success
    else
      respond_destroy_error
    end
  end

  def new
    respond_to do |format|
      format.mobile { render layout: false }
    end
  end

  def index
    comments = comment_service.find_for_post(params[:post_id])
    respond_with do |format|
      format.json { render json: CommentPresenter.as_collection(comments), status: 200 }
      format.mobile { render layout: false, locals: {comments: comments} }
    end
  end

  private

  def comment_service
    @comment_service ||= CommentService.new(current_user)
  end

  def respond_create_success(comment)
    respond_to do |format|
      format.json { render json: CommentPresenter.new(comment), status: 201 }
      format.html { render nothing: true, status: 201 }
      format.mobile { render partial: "comment", locals: {comment: comment} }
    end
  end

  def respond_destroy_success
    respond_to do |format|
      format.mobile { redirect_to :back }
      format.js { render nothing: true, status: 204 }
      format.json { render nothing: true, status: 204 }
    end
  end

  def respond_destroy_error
    respond_to do |format|
      format.mobile { redirect_to :back }
      format.js { render nothing: true, status: 403 }
      format.json { render nothing: true, status: 403 }
    end
  end
end
