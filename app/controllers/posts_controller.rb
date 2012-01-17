#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, "lib", "stream", "aspect")
require File.join(Rails.root, "lib", "stream", "multi")
require File.join(Rails.root, "lib", "stream", "comments")
require File.join(Rails.root, "lib", "stream", "likes")
require File.join(Rails.root, "lib", "stream", "mention")
require File.join(Rails.root, "lib", "stream", "followed_tag")

class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => :show
  before_filter :set_format_if_malformed_from_status_net, :only => :show

  before_filter :redirect_unless_admin, :only => :public

  before_filter :save_selected_aspects, :only => :aspects
  before_filter :ensure_page, :only => :aspects

  respond_to :html,
             :mobile,
             :json,
             :xml

  def show
    key = params[:id].to_s.length <= 8 ? :id : :guid

    if user_signed_in?
      @post = current_user.find_visible_shareable_by_id(Post, params[:id], :key => key)
      @commenting_disabled = user_can_not_comment_on_post?
    else
      @post = Post.where(key => params[:id], :public => true).includes(:author, :comments => :author).first
      @commenting_disabled = true
    end

    if @post
      # mark corresponding notification as read
      if user_signed_in? && notification = Notification.where(:recipient_id => current_user.id, :target_id => @post.id).first
        notification.unread = false
        notification.save
      end

      respond_to do |format|
        format.xml{ render :xml => @post.to_diaspora_xml }
        format.mobile{render 'posts/show.mobile.haml'}
        format.json{ render :json => {:posts => @post.as_api_response(:backbone)}, :status => 201 }
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
        format.all {redirect_to multi_stream_path}
      end
    else
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
      render :nothing => true, :status => 404
    end
  end

  # streams
  def aspects
    stream_klass = Stream::Aspect
    aspect_ids = (session[:a_ids] ? session[:a_ids] : [])
    @stream = Stream::Aspect.new(current_user, aspect_ids,
                                 :max_time => params[:max_time].to_i)

    respond_with do |format|
      format.html { render 'aspects/index' }
      format.json{ render_for_api :backbone, :json => @stream.stream_posts, :root => :posts }
    end
  end

  def public
    stream_responder(Stream::Public)
  end

  def multi
    stream_responder(Stream::Multi)
  end

  def commented
    stream_responder(Stream::Comments)
  end

  def liked
    stream_responder(Stream::Likes)
  end

  def mentioned
    stream_responder(Stream::Mention)
  end

  def followed_tags
    stream_responder(Stream::FollowedTag)
  end

  private

  def stream_responder(stream_klass)
    respond_with do |format|
      format.html{ default_stream_action(stream_klass) }
      format.mobile{ default_stream_action(stream_klass) }
      format.json{ stream_json(stream_klass) }
    end
  end

  def set_format_if_malformed_from_status_net
   request.format = :html if request.format == 'application/html+xml'
  end

  def user_can_not_comment_on_post?
    if @post.public && @post.author.local?
      false
    elsif current_user.contact_for(@post.author)
      false
    elsif current_user.owns?(@post)
      false
    else
      true
    end
  end

  def save_selected_aspects
    if params[:a_ids].present?
      session[:a_ids] = params[:a_ids]
    end
  end

  def ensure_page
    params[:max_time] ||= Time.now + 1
  end
end
