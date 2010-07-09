class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 
  def index
    @local_requests = Request.from_user( User.first )
    @remote_requests = Request.for_user( User.first )

    @request = Request.new
  end
  
  def destroy
    @request = Request.where(:id => params[:id]).first
    @request.destroy
    flash[:notice] = "Successfully destroyed person request."
    redirect_to person_requests_url
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.send_friend_request_to(params[:request][:destination_url])

    if @request
      flash[:notice] = "Successfully created person request."
      redirect_to person_requests_url
    else
      render :action => 'new'
    end
  end


end
