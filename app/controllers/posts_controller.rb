  #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("app", "presenters", "post_presenter")

class PostsController < ApplicationController
  include PostsHelper

  before_filter :authenticate_user!, :except => [:show, :iframe, :oembed, :interactions]
  before_filter :set_format_if_malformed_from_status_net, :only => :show
  before_filter :find_post, :only => [:next, :previous, :interactions]

  layout 'post'

  respond_to :html,
             :mobile,
             :json,
             :xml

  rescue_from Diaspora::NonPublic do |exception|
    respond_to do |format|
      format.all { render :template=>'errors/not_public', :status=>403 }
    end
  end

  def show
    @post = Post.find_by_guid_or_id_with_user(params[:id], current_user)
    mark_corresponding_notification_read if user_signed_in?
    respond_to do |format|
      format.html{ gon.post = PostPresenter.new(@post, current_user); render 'posts/show' }
      format.xml{ render :xml => @post.to_diaspora_xml }
      format.mobile{render 'posts/show', :layout => "application"}
      format.json{ render :json => PostPresenter.new(@post, current_user) }
    end
  end

  def iframe
    render :text => post_iframe_url(params[:id]), :layout => false
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    begin
      post = Post.find_by_guid_or_id_with_user(post_id, current_user)
      oembed = OEmbedPresenter.new(post, params.slice(:format, :maxheight, :minheight))
      render :json => oembed
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 404
    end
  end

  def next
    next_post = Post.visible_from_author(@post.author, current_user).newer(@post)

    respond_to do |format|
      format.html{ redirect_to post_path(next_post) }
      format.json{ render :json => PostPresenter.new(next_post, current_user)}
    end
  end

  def previous
    previous_post = Post.visible_from_author(@post.author, current_user).older(@post)

    respond_to do |format|
      format.html{ redirect_to post_path(previous_post) }
      format.json{ render :json => PostPresenter.new(previous_post, current_user)}
    end
  end

  def interactions
    respond_with(PostInteractionPresenter.new(@post, current_user))
  end

  def destroy
    find_current_user_post(params[:id])
    current_user.retract(@post)

    respond_to do |format|
      format.js { render 'destroy',:layout => false,  :format => :js }
      format.json { render :nothing => true, :status => 204 }
      format.any { redirect_to stream_path }
    end
  end

  def update
    find_current_user_post(params[:id])
    @post.favorite = !@post.favorite
    @post.save
    render :nothing => true, :status => 202
  end

  protected

  def find_post #checks whether current user can see it
    begin
      @post = Post.find_by_guid_or_id_with_user(params[:id], current_user)
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 404
    end
  end

  def find_current_user_post(id) #makes sure current_user can modify
    @post = current_user.posts.find(id)
  end

  def set_format_if_malformed_from_status_net
   request.format = :html if request.format == 'application/html+xml'
  end

  def mark_corresponding_notification_read
    if notification = Notification.where(:recipient_id => current_user.id, :target_id => @post.id, :unread => true).first
      notification.unread = false
      notification.save
    end
  end
end
