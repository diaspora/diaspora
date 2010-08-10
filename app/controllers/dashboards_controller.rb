class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper

  def index
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC'
  end
end
