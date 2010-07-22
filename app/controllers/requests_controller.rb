class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 
  def index
    @remote_requests = Request.for_user( current_user )
    @request = Request.new
  end
  
  def destroy
    if params[:accept]
      @friend = current_user.accept_friend_request params[:id]
      
      flash[:notice] = "you are now friends"
      redirect_to root_url 
    else
      current_user.ignore_friend_request params[:id]
      flash[:notice] = "ignored friend request"
      redirect_to requests_url
    end

  end
  
  def new
    @request = Request.new
  end
  
  def create
    rel_hash = relationship_flow(params[:request][:destination_url])
    @request = current_user.send_request(rel_hash)

    if @request
      flash[:notice] = "a friend request was sent to #{@request.destination_url}"
      redirect_to requests_url
    else
      if url.include? '@'
        flash[:error] = "no diaspora seed found with this email!"
      else
        flash[:error] = "you have already friended this person"
      end
      @request = Request.new
      render :action => 'new'
    end
  end


  
  private 


end
