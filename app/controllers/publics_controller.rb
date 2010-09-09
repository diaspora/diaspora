class PublicsController < ApplicationController
  require 'lib/diaspora/parser'
  include Diaspora::Parser
  
  def hcard
    @person = Person.find_by_id params[:id]

    unless @person.nil? || @person.owner.nil?
      render 'hcard'
    end
  end

  def host_meta
    render 'host_meta', :layout => false, :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.by_webfinger(params[:q])
    unless @person.nil? || @person.owner.nil?
      render 'webfinger', :layout => false, :content_type => 'application/xrd+xml'
    end
  end
  
  def receive
    render :nothing => true
    return unless params[:xml]
    begin
      @user = Person.first(:id => params[:id]).owner
    rescue NoMethodError => e
      Rails.logger.error("Received post #{params[:xml]} for nonexistent person #{params[:id]}")
      return
    end
    puts params[:xml]
    if params[:xml].include? "xml version='1.0'"
      @user.receive_salmon params[:xml]
    else
      @user.receive params[:xml]
    end
  end
  
end
