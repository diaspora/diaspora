  #   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  require File.join(Rails.root, '/lib/diaspora/parser')
  include Diaspora::Parser

  skip_before_filter :set_header_data
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender
  before_filter :allow_cross_origin, :only => [:hcard, :host_meta, :webfinger]

  respond_to :html
  respond_to :xml, :only => :post

  def allow_cross_origin
    headers["Access-Control-Allow-Origin"] = "*"
  end

  layout false
  caches_page :host_meta

  def hcard
    @person = Person.where(:guid => params[:guid]).first
    unless @person.nil? || @person.owner.nil?
      render 'publics/hcard'
    else
      render :nothing => true, :status => 404
    end
  end

  def host_meta
    render 'host_meta', :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.local_by_account_identifier(params[:q]) if params[:q]
    unless @person.nil?
      render 'webfinger', :content_type => 'application/xrd+xml'
    else
      render :nothing => true, :status => 404
    end
  end

  def hub
    render :text => params['hub.challenge'], :status => 202, :layout => false
  end

  def receive
    if params[:xml].nil?
      render :nothing => true, :status => 422
      return
    end

    person = Person.where(:guid => params[:guid]).first

    if person.nil? || person.owner_id.nil?
      Rails.logger.error("Received post for nonexistent person #{params[:guid]}")
      render :nothing => true, :status => 404
      return
    end

    @user = person.owner
    Resque.enqueue(Job::ReceiveSalmon, @user.id, CGI::unescape(params[:xml]))

    render :nothing => true, :status => 202
  end

  def post

    if params[:guid].to_s.length <= 8
      @post = Post.where(:id => params[:guid], :public => true).includes(:author, :comments => :author).first
    else
      @post = Post.where(:guid => params[:guid], :public => true).includes(:author, :comments => :author).first
    end

    #hax to upgrade logged in users who can comment
    if @post
      if user_signed_in? && current_user.find_visible_post_by_id(@post.id)
        redirect_to post_path(@post)
      else
        @landing_page = true
        @person = @post.author
        if @person.owner_id
          I18n.locale = @person.owner.language

          respond_to do |format|
            format.all{ render "#{@post.class.to_s.underscore}", :layout => 'application'}
            format.xml{ render :xml => @post.to_diaspora_xml }
          end
        else
          flash[:error] = I18n.t('posts.show.not_found')
          redirect_to root_url
        end
      end
    else
      flash[:error] = I18n.t('posts.show.not_found')
      redirect_to root_url
    end
  end
end
