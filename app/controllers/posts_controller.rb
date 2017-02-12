#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  before_action :authenticate_user!, only: :destroy
  before_action :set_format_if_malformed_from_status_net, only: :show

  respond_to :html, :mobile, :json, :xml

  rescue_from Diaspora::NonPublic do
    authenticate_user!
  end

  rescue_from Diaspora::NotMine do
    render text: I18n.t("posts.show.forbidden"), status: 403
  end

  def show
    post = post_service.find!(params[:id])
    post_service.mark_user_notifications(post.id)
    presenter = PostPresenter.new(post, current_user)
    respond_to do |format|
      format.html do
        gon.post = presenter
        render locals: {post: presenter}
      end
      format.mobile { render locals: {post: post} }
      format.xml { render xml: DiasporaFederation::Salmon::XmlPayload.pack(Diaspora::Federation::Entities.post(post)) }
      format.json { render json: presenter }
    end
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    post = post_service.find!(post_id)
    oembed = params.slice(:format, :maxheight, :minheight)
    render json: OEmbedPresenter.new(post, oembed)
  rescue
    render nothing: true, status: 404
  end

  def interactions
    respond_to do |format|
      format.json {
        post = post_service.find!(params[:id])
        render json: PostInteractionPresenter.new(post, current_user)
      }
      format.any { render nothing: true, status: 406 }
    end
  end

  def destroy
    post_service.destroy(params[:id])
    respond_to do |format|
      format.json { render nothing: true, status: 204 }
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
