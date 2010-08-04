class PublicsController < ApplicationController
  require 'lib/diaspora/parser'
  include Diaspora::Parser
  
  def hcard
    @user = User.owner
    render 'hcard'
  end

  def host_meta
    @user = User.owner
    render 'host_meta', :layout => false, :content_type => 'application/xrd+xml'
  end

  def webfinger
    @user = Person.first(:email => params[:q].gsub('acct:', ''))
    render 'webfinger', :layout => false, :content_type => 'application/xrd+xml'
  end
  
  def receive
    puts "SOMEONE JUST SENT ME: #{params[:xml]}"
    store_objects_from_xml params[:xml]
    render :nothing => true
  end
  
end
