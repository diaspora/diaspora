class PublicsController < ApplicationController
  include ApplicationHelper
  include PublicsHelper
  
  def hcard
  end

  def host_meta
    @user = User.owner
    render 'host_meta', :layout => false, :content_type => 'application/xrd+xml'
  end

  def webfinger
    @user = Person.first(:email => params[:q])
    render 'webfinger', :layout => false, :content_type => 'application/xrd+xml'
  end
  
  def hubbub
      if params['hub.mode'] == "subscribe"
        render :text => params['hub.challenge'], :status => 202 
      end
  end

end
