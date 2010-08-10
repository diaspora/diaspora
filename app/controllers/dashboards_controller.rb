class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper

  def index
    if params[:group]
      @people_ids = @group.people.map {|p| p.id}

      @posts = Post.paginate :person_id => @people_ids, :order => 'created_at DESC'
    else
      @posts = Post.paginate :page => params[:page], :order => 'created_at DESC'
    end
  end
end
