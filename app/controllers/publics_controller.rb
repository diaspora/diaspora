  #   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  require File.join(Rails.root, '/lib/diaspora/parser')
  include Diaspora::Parser

  skip_before_filter :set_header_data
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender

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
end
