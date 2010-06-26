class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.sort(:created_at.desc).all
  end


  def receive
    store_posts_from_xml CGI::unescape(params[:xml])
    render :nothing => true
  end
  
  def socket
  #this is just for me to test teh sockets!
    render "socket"   
  end
end
