#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  include PostsHelper

  before_action :authenticate_user!, :except => [:show, :iframe, :oembed, :interactions]
  before_action :set_format_if_malformed_from_status_net, :only => :show

  use_bootstrap_for :show

  respond_to :html,
             :mobile,
             :json,
             :xml

  rescue_from Diaspora::NonPublic do |exception|
    respond_to do |format|
      format.all { @css_framework = :bootstrap; render :template=>'errors/not_public', :status=>404, :layout => "application"}
    end
  end

  def show
    mark_corresponding_notifications_read if user_signed_in?

    respond_to do |format|
      format.html{ gon.post = PostPresenter.new(@post, current_user); render 'posts/show', layout: 'with_header_with_footer' }
      format.xml{ render :xml => @post.to_diaspora_xml }
      format.mobile{render 'posts/show' }
      format.json{ render :json => PostPresenter.new(@post, current_user) }
    end
  end

  def iframe
    render :text => post_iframe_url(params[:id]), :layout => false
  end

  def oembed
    post_id = OEmbedPresenter.id_from_url(params.delete(:url))
    post = Post.find_by_guid_or_id_with_user(post_id, current_user)
    if post.present?
      oembed = OEmbedPresenter.new(post, params.slice(:format, :maxheight, :minheight))
      render :json => oembed
    else
      render :nothing => true, :status => 404
    end
  end

  def interactions
    respond_with(PostInteractionPresenter.new(@post, current_user))
  end

  def destroy
    find_current_user_post(params[:id])
    current_user.retract(@post)

    respond_to do |format|
      format.js { render 'destroy',:layout => false, :format => :js }
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
    @post = Post.find_by_guid_or_id_with_user(params[:id], current_user)
  end

  def find_current_user_post(id) #makes sure current_user can modify
    @post = current_user.posts.find(id)
  end

  def set_format_if_malformed_from_status_net
   request.format = :html if request.format == 'application/html+xml'
  end

  def mark_corresponding_notifications_read
    # For comments, reshares, likes
    Notification.where(recipient_id: current_user.id, target_type: "Post", target_id: @post.id, unread: true).each do |n|
      n.set_read_state( true )
    end

    # For mentions
    mention = @post.mentions.where(person_id: current_user.person_id).first
    Notification.where(recipient_id: current_user.id, target_type: "Mention", target_id: mention.id, unread: true).first.try(:set_read_state, true) if mention
  end
end
