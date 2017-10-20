# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i(destroy mentionable)
  before_action :set_format_if_malformed_from_status_net, only: :show

  respond_to :html, :mobile, :json

  rescue_from Diaspora::NonPublic do
    authenticate_user!
  end

  rescue_from Diaspora::NotMine do
    render plain: I18n.t("posts.show.forbidden"), status: 403
  end

  def show
    post = post_service.find!(params[:id])
    post_service.mark_user_notifications(post.id)
    presenter = PostPresenter.new(post, current_user)
    respond_to do |format|
      format.html do
        gon.post = presenter.with_initial_interactions
        render locals: {post: presenter}
      end
      format.mobile { render locals: {post: post} }
      format.json { render json: presenter.with_interactions }
    end
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    post = post_service.find!(post_id)
    oembed = params.slice(:format, :maxheight, :minheight)
    render json: OEmbedPresenter.new(post, oembed)
  rescue
    head :not_found
  end

  def mentionable
    respond_to do |format|
      format.json {
        if params[:id].present? && params[:q].present?
          render json: post_service.mentionable_in_comment(params[:id], params[:q])
        else
          head :no_content
        end
      }
      format.any { head :not_acceptable }
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroy
    post_service.destroy(params[:id])
    respond_to do |format|
      format.json { head :no_content }
      format.any { redirect_to stream_path }
    end
  end

  private

  def post_service
    @post_service ||= PostService.new(current_user)
  end

  def set_format_if_malformed_from_status_net
    request.format = :html if request.format == "application/html+xml"
  end
end
