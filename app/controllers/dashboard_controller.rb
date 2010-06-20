class DashboardController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @bookmarks = Bookmark.all
    @messages = StatusMessage.all
  end


  def receive
    store_posts_from_xml (params[:xml])
    render :nothing => true
  end
end
