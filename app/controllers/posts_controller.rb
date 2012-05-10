  #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("app", "presenters", "post_presenter")

class PostsController < ApplicationController
  include PostsHelper
  
  before_filter :authenticate_user!, :except => [:show, :iframe, :oembed]
  before_filter :set_format_if_malformed_from_status_net, :only => :show
  before_filter :find_post, :only => [:show, :next, :previous]

  layout 'post'

  respond_to :html,
             :mobile,
             :json,
             :xml

  def new
    @feature_flag = FeatureFlagger.new(current_user, current_user.person) #I should be a global before filter so @feature_flag is accessible
    redirect_to "/stream" and return unless @feature_flag.new_publisher?
    render :text => "", :layout => true
  end

  def show
    return log_and_redirect_back unless @post

    mark_corresponding_notification_read if user_signed_in?

    respond_to do |format|
      format.html{ gon.post = post_json(@post); render 'posts/show.html.haml' }
      format.xml{ render :xml => @post.to_diaspora_xml }
      format.mobile{render 'posts/show.mobile.haml', :layout => "application"}
      format.json{ render :json => post_json(@post) }
    end
  end

  def iframe
    render :text => post_iframe_url(params[:id]), :layout => false
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    post = find_by_guid_or_id_with_current_user(post_id) 
    if post.present?
      oembed = OEmbedPresenter.new(post, params.slice(:format, :maxheight, :minheight))
      render :json => oembed
    else
      render :nothing => true, :status => 404
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

  def update
    @post = current_user.posts.find(params[:id])
    if @post
      @post.favorite = !@post.favorite
      @post.save
      render :nothing => true, :status => 202
    end
  end

  def next
    next_post = visible_posts_from_author.newer(@post)

    respond_to do |format|
      format.html{ redirect_to post_path(next_post) }
      format.json{ render :json => post_json(next_post) }
    end
  end

  def previous
    previous_post = visible_posts_from_author.older(@post)

    respond_to do |format|
      format.html{ redirect_to post_path(previous_post) }
      format.json{ render :json => post_json(previous_post) }
    end
  end

  protected

  def log_and_redirect_back #preserving old functionality, but this should probably be removed
    user_id = (user_signed_in? ? current_user : nil)
    Rails.logger.info(":event => :link_to_nonexistent_post, :ref => #{request.env['HTTP_REFERER']}, :user_id => #{user_id}, :post_id => #{params[:id]}")
    flash[:error] = I18n.t('posts.show.not_found')
    redirect_to :back
  end

  def find_post
    @post = find_by_guid_or_id_with_current_user(params[:id])
  end

  def visible_posts_from_author
    Post.visible_from_author(@post.author, current_user)
  end

  def post_json(post)
    PostPresenter.new(post, current_user).to_json
  end

  def find_by_guid_or_id_with_current_user(id)
    key = id.to_s.length <= 8 ? :id : :guid
    if user_signed_in?
      current_user.find_visible_shareable_by_id(Post, id, :key => key)
    else
      Post.where(key => id, :public => true).includes(:author, :comments => :author).first
    end
  end

  def set_format_if_malformed_from_status_net
   request.format = :html if request.format == 'application/html+xml'
  end

  def mark_corresponding_notification_read
    if notification = Notification.where(:recipient_id => current_user.id, :target_id => @post.id).first
      notification.unread = false
      notification.save
    end
  end
end
