#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  require File.expand_path('../../../lib/diaspora/parser', __FILE__)
  require File.expand_path('../../../lib/diaspora/ostatus_builder', __FILE__)
  include Diaspora::Parser

  layout false

  def hcard
    @person = Person.find_by_id params[:id]
    unless @person.nil? || @person.owner.nil?
      render 'hcard'
    end
  end

  def host_meta
    render 'host_meta', :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.by_webfinger(params[:q], :local => true) if params[:q]
    unless @person.nil? || @person.owner.nil?
      render 'webfinger', :content_type => 'application/xrd+xml'
    else
      render :nothing => true
    end
  end

  def receive
    render :nothing => true
    return unless params[:xml]
    begin
      person = Person.first(:id => params[:id])
      @user = person.owner
    rescue NoMethodError => e
      Rails.logger.error("Received post for nonexistent person #{params[:id]}")
      return
    end
    @user.receive_salmon params[:xml]
  end

  def public
    user = User.find_by_username(params[:username])

    director = Diaspora::Director.new
    ostatus_builder = Diaspora::OstatusBuilder.new(user)

    render :xml => director.build(ostatus_builder)
  end

end
