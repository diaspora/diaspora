class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.stream
  end


  def receive
    store_posts_from_xml (params[:xml])



    puts "holy boner batman"
    render :nothing => true
  end
end
