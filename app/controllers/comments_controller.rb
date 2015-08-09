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
    @comment = CommentService.new(post_id: params[:post_id], text: params[:text], user: current_user).create_comment
    if @comment
      respond_create_success
    else
      render nothing: true, status: 404
    end
  end

  def destroy
    service = CommentService.new(comment_id: params[:id], user: current_user)
    if service.destroy_comment
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
    service = CommentService.new(post_id: params[:post_id], user: current_user)
    @post = service.post
    @comments = service.comments
    respond_with do |format|
      format.json  { render json: CommentPresenter.as_collection(@comments), status: 200 }
      format.mobile { render layout: false }
    end
  end

  private

  def respond_create_success
    respond_to do |format|
      format.json { render json: CommentPresenter.new(@comment), status: 201 }
      format.html { render nothing: true, status: 201 }
      format.mobile { render partial: "comment", locals: {post: @comment.post, comment: @comment} }
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
