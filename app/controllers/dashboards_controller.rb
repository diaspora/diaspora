class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper

  def index
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def ostatus
    @posts = OstatusPost.paginate :page => params[:page], :order => 'published_at DESC'
    render :index
  end
  
  end
