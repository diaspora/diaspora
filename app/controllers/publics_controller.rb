  #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require File.join(Rails.root, 'lib', 'stream', 'public_stream')

class PublicsController < ApplicationController
  require File.join(Rails.root, '/lib/diaspora/parser')
  require File.join(Rails.root, '/lib/postzord/receiver/public')
  require File.join(Rails.root, '/lib/postzord/receiver/private')
  include Diaspora::Parser

  skip_before_filter :set_header_data
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender
  before_filter :allow_cross_origin, :only => [:hcard, :host_meta, :webfinger]
  before_filter :check_for_xml, :only => [:receive, :receive_public]
  before_filter :authenticate_user!, :only => [:index]

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

  def receive_public
    Resque.enqueue(Jobs::ReceiveUnencryptedSalmon, CGI::unescape(params[:xml]))
    render :nothing => true, :status => :ok
  end

  def receive
    person = Person.where(:guid => params[:guid]).first

    if person.nil? || person.owner_id.nil?
      Rails.logger.error("Received post for nonexistent person #{params[:guid]}")
      render :nothing => true, :status => 404
      return
    end

    @user = person.owner
    Resque.enqueue(Jobs::ReceiveEncryptedSalmon, @user.id, CGI::unescape(params[:xml]))

    render :nothing => true, :status => 202
  end


  private

  def check_for_xml
    if params[:xml].nil?
      render :nothing => true, :status => 422
      return
    end
  end
end
