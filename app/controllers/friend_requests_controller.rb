class FriendRequestsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @friend_requests = FriendRequest.paginate :page => params[:page], :order => 'created_at DESC'
    @friend_request = FriendRequest.new
    @person = Person.new
  end
  
  def show
    @friend_request = FriendRequest.where(:id => params[:id]).first
  end
  
  def destroy
    @friend_request = FriendRequest.where(:id => params[:id]).first
    @friend_request.destroy
    flash[:notice] = "Successfully destroyed friend request."
    redirect_to friend_requests_url
  end
  
  def new
    @friend_request = FriendRequest.new
    @recipient = Person.new
  end
  
  def create

    @friend_request = FriendRequest.new(params[:friend_request])
    @friend_request.sender = Person.new( :email => User.first.email, :url => User.first.url )
    puts
    puts
    puts params.inspect


    if @friend_request.save
      flash[:notice] = "Successfully created friend request."
      redirect_to @friend_request
    else
      render :action => 'new'
    end
  end
end
