class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.stream
  end


  def receive
    store_posts_from_xml (params[:xml])
    render :nothing => true
  end
  
  def socket
  #this is just for me to test teh sockets!
    render "socket"   
  end
end
