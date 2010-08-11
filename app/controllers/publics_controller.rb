class PublicsController < ApplicationController
  require 'lib/diaspora/parser'
  include Diaspora::Parser
  
  def hcard
    @person = Person.first(:_id => params[:id])

    unless @person.nil? || @person.owner.nil?
      render 'hcard'
    end
  end

  def host_meta
    @user = User.owner
    render 'host_meta', :layout => false, :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.first(:email => params[:q].gsub('acct:', ''))
    unless @person.nil? || @person.owner.nil?
      render 'webfinger', :layout => false, :content_type => 'application/xrd+xml'
    end
  end
  
  def receive
    @user = Person.first(:id => params[:id]).owner
    Rails.logger.debug "PublicsController has received: #{params[:xml]}"
    store_from_xml params[:xml], @user
    render :nothing => true
  end
  
end
