require File.join(Rails.root, 'lib', 'stream', 'featured_users_stream')

class FeaturedUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_sort_order, :only => :index

  def index
    @stream = FeaturedUsersStream.new(current_user, :max_time => params[:max_time], :order => sort_order)
    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @stream.posts}
    else
      render 'aspects/index'
    end 
  end
end
