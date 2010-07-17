class PublicsController < ApplicationController
  include ApplicationHelper
  include PublicsHelper
  
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
  
  def hubbub
      if params['hub.mode'] == 'subscribe' || params['hub.mode'] == 'unsubscribe'
        render :text => params['hub.challenge'], :status => 202 
      end
  end
  
  def receive
    puts "SOMEONE JUST SENT ME: #{params[:xml]}"
    store_objects_from_xml params[:xml]
    render :nothing => true
  end
  
end
