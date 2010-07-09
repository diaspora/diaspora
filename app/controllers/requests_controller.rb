class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 
  def index
    @remote_requests = Request.for_user( current_user )
    @request = Request.new
  end
  
  def destroy
    @request = Request.where(:id => params[:id]).first
    @request.destroy
    flash[:notice] = "Successfully destroyed person request."
    redirect_to requests_url
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.send_friend_request_to(params[:request][:destination_url])

    if @request
      flash[:notice] = "a friend request was sent to #{@request.destination_url}"
      redirect_to requests_url
    else
      render :action => 'new'
    end
  end
end
