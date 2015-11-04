#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  include PostsHelper

  before_action :authenticate_user!, only: :destroy
  before_action :set_format_if_malformed_from_status_net, only: :show

  respond_to :html, :mobile, :json, :xml

  rescue_from Diaspora::NonPublic do
    if user_signed_in?
      @code = "not-public"
      respond_to do |format|
        format.all { render template: "errors/not_public", status: 404, layout: "error_page" }
      end
    else
      authenticate_user!
    end
  end

  rescue_from Diaspora::NotMine do
    render text: "You are not allowed to do that", status: 403
  end

  def show
    post_service = PostService.new(id: params[:id], user: current_user)
    post_service.mark_user_notifications
    @post = post_service.post
    respond_to do |format|
      format.html { gon.post = post_service.present_json }
      format.xml { render xml: @post.to_diaspora_xml }
      format.json { render json: post_service.present_json }
    end
  end

  def iframe
    render text: post_iframe_url(params[:id]), layout: false
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    post_service = PostService.new(id: post_id, user: current_user,
                                    oembed: params.slice(:format, :maxheight, :minheight))
    render json: post_service.present_oembed
  end

  def interactions
    post_service = PostService.new(id: params[:id], user: current_user)
    respond_with post_service.present_interactions_json
  end

  def destroy
    post_service = PostService.new(id: params[:id], user: current_user)
    post_service.retract_post
    @post = post_service.post
    respond_to do |format|
      format.js { render "destroy", layout: false, format: :js }
      format.json { render nothing: true, status: 204 }
      format.any { redirect_to stream_path }
    end
  end

  private

  def set_format_if_malformed_from_status_net
    request.format = :html if request.format == "application/html+xml"
  end
end
