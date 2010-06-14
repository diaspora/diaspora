class FriendsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @friends = Friend.all
  end
  
  def show
    @friend = Friend.first(:conditions=> {:id => params[:id]})
  end
  
  def destroy
    @friend = Friend.first(:conditions=> {:id => params[:id]})
    @friend.destroy
    flash[:notice] = "Successfully destroyed friend."
    redirect_to friends_url
  end
  
  def new
    @friend = Friend.new
  end
  
  def create
    @friend = Friend.new(params[:friend])
    if @friend.save
      flash[:notice] = "Successfully created friend."
      redirect_to @friend
    else
      render :action => 'new'
    end
  end
end
