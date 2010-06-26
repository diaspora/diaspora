class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.sort(:created_at.desc).all
  end


  def receive
    xml = CGI::unescape(params[:xml])
    puts xml
    store_objects_from_xml xml
    render :nothing => true
  end
  
  def socket
  #this is just for me to test teh sockets!
    render "socket"   
  end
end
