#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("app", "presenters", "post_presenter")

class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => :show
  before_filter :set_format_if_malformed_from_status_net, :only => :show

  layout 'post'

  respond_to :html,
             :mobile,
             :json,
             :xml

  def new

  end

  def show
    key = params[:id].to_s.length <= 8 ? :id : :guid

    if user_signed_in?
      @post = current_user.find_visible_shareable_by_id(Post, params[:id], :key => key)
    else
      @post = Post.where(key => params[:id], :public => true).includes(:author, :comments => :author).first
    end

    if @post
      # @commenting_disabled = can_not_comment_on_post?
      # mark corresponding notification as read
      if user_signed_in? && notification = Notification.where(:recipient_id => current_user.id, :target_id => @post.id).first
        notification.unread = false
        notification.save
      end

      respond_to do |format|
        format.xml{ render :xml => @post.to_diaspora_xml }
        format.mobile{render 'posts/show.mobile.haml'}
        format.json{ render :json => PostPresenter.new(@post, current_user).to_json }
         format.any{render 'posts/show.html.haml'}
      end

    else
      user_id = (user_signed_in? ? current_user : nil)
      Rails.logger.info(":event => :link_to_nonexistent_post, :ref => #{request.env['HTTP_REFERER']}, :user_id => #{user_id}, :post_id => #{params[:id]}")
      flash[:error] = I18n.t('posts.show.not_found')
      redirect_to :back
    end
  end

  def destroy
    @post = current_user.posts.where(:id => params[:id]).first
    if @post
      current_user.retract(@post)
      respond_to do |format|
        format.js {render 'destroy'}
        format.json { render :nothing => true, :status => 204 }
        format.all {redirect_to stream_path}
      end
    else
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
      render :nothing => true, :status => 404
    end
  end

  private

  def set_format_if_malformed_from_status_net
   request.format = :html if request.format == 'application/html+xml'
  end

  def can_not_comment_on_post?
    if !user_signed_in?
      true
    elsif @post.public && @post.author.local?
      false
    elsif current_user.contact_for(@post.author)
      false
    elsif current_user.owns?(@post)
      false
    else
      true
    end
  end
end
