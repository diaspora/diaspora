  #   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  require File.join(Rails.root, '/lib/diaspora/parser')
  include Diaspora::Parser

  skip_before_filter :set_friends_and_status, :except => [:create, :update]
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :set_locale

  layout false

  def hcard
    @person = Person.find_by_id params[:id]
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
    if params['hub.mode'] == 'subscribe' || params['hub.mode'] == 'unsubscribe'
      render :text => params['hub.challenge'], :status => 202, :layout => false
      end
  end

  def receive
    if params[:xml].nil?
      render :nothing => true, :status => 422
      return
    end

    person = Person.first(:id => params[:id])

    if person.owner_id.nil?
      Rails.logger.error("Received post for nonexistent person #{params[:id]}")
      render :nothing => true, :status => 404
      return
    end

    @user = person.owner
     
    begin
      @user.receive_salmon(params[:xml])
    rescue Exception => e
      Rails.logger.info("bad salmon: #{e.message}")
    end

    render :nothing => true, :status => 200
  end
end
