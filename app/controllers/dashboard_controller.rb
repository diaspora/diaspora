class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC'
  end


  def receive
    store_objects_from_xml CGI::unescape(params[:xml])
    render :nothing => true
  end
  
  def socket
  #this is just for me to test teh sockets!
    render "socket"   
  end
end
