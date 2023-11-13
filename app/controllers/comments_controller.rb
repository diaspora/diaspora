# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  before_action :authenticate_user!, except: :index

  respond_to :html, :mobile, :json

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  rescue_from Diaspora::NonPublic do
    authenticate_user!
  end

  def index
    comments = comment_service.find_for_post(params[:post_id])
    respond_with do |format|
      format.json { render json: CommentPresenter.as_collection(comments, :as_json, current_user), status: :ok }
      format.mobile { render layout: false, locals: {comments: comments} }
    end
  end

  def new
    respond_to do |format|
      format.mobile { render layout: false }
    end
  end

  def create
    begin
      comment = comment_service.create(params[:post_id], params[:text])
    rescue ActiveRecord::RecordNotFound
      render plain: I18n.t("comments.create.error"), status: :not_found
      return
    end

    if comment
      respond_create_success(comment)
    else
      render plain: I18n.t("comments.create.error"), status: :unprocessable_entity
    end
  end

  def destroy
    if comment_service.destroy(params[:id])
      respond_destroy_success
    else
      respond_destroy_error
    end
  end

  private

  def comment_service
    @comment_service ||= CommentService.new(current_user)
  end

  def respond_create_success(comment)
    respond_to do |format|
      format.json { render json: CommentPresenter.new(comment), status: 201 }
      format.html { head :created }
      format.mobile { render partial: "comment", locals: {comment: comment} }
    end
  end

  def respond_destroy_success
    respond_to do |format|
      format.mobile { redirect_back fallback_location: stream_path }
      format.js { head :no_content }
      format.json { head :no_content }
    end
  end

  def respond_destroy_error
    respond_to do |format|
      format.mobile { redirect_back fallback_location: stream_path }
      format.js { head :forbidden }
      format.json { head :forbidden }
    end
  end
end
