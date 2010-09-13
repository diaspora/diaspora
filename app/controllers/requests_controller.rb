class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 

  respond_to :html
  respond_to :json, :only => :index

  def index
    @remote_requests = Request.for_user current_user
    @request         = Request.new

    respond_with @remote_requests
  end
  
  def destroy
    if params[:accept]
      if params[:aspect_id]
        @friend = current_user.accept_and_respond( params[:id], params[:aspect_id])
        flash[:notice] = "you are now friends"
        respond_with :location => current_user.aspect_by_id(params[:aspect_id])
      else
        flash[:error] = "please select a aspect!"
        respond_with :location => requests_url
      end
    else
      current_user.ignore_friend_request params[:id]
      respond_with :location => requests_url, :notice => "Ignored friend request."
    end
  end
  
  def new
    @request = Request.new
  end
  
  def create
    aspect = current_user.aspect_by_id(params[:request][:aspect_id])

    begin 
      rel_hash = relationship_flow(params[:request][:destination_url])
    rescue Exception => e
      respond_with :location => aspect, :error => "No diaspora seed found with this email!" 
      return
    end
    
    Rails.logger.debug("Sending request: #{rel_hash}")
    
    begin
      @request = current_user.send_friend_request_to(rel_hash[:friend], aspect)
    rescue Exception => e
      raise e unless e.message.include? "already friends"
      message = "You are already friends with #{params[:request][:destination_url]}!"
      respond_with :location => aspect, :notice => message
      return
    end

    if @request
      message = "A friend request was sent to #{@request.destination_url}."
      respond_with :location => aspect, :notice => message
    else
      message = "Something went horribly wrong."
      respond_with :location => aspect, :error => message
    end
  end

end
