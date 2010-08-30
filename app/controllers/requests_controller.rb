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
      if params[:group_id]
        @friend = current_user.accept_and_respond( params[:id], params[:group_id])
        flash[:notice] = "you are now friends"
        respond_with :location => current_user.group_by_id(params[:group_id])
      else
        flash[:error] = "please select a group!"
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
    group = current_user.group_by_id(params[:request][:group_id])

    begin 
      rel_hash = relationship_flow(params[:request][:destination_url])
    rescue Exception => e
      respond_with :location => group, :error => "No diaspora seed found with this email!" 
      return
    end
    
    Rails.logger.debug("Sending request: #{rel_hash}")
    
    begin
      @request = current_user.send_request(rel_hash, params[:request][:group_id])
    rescue Exception => e
      raise e unless e.message.include? "already friends"
      message = "You are already friends with #{params[:request][:destination_url]}!"
      respond_with :location => group, :notice => message
      return
    end

    if @request
      message = "A friend request was sent to #{@request.destination_url}."
      respond_with :location => group, :notice => message
    else
      message = "Something went horribly wrong."
      respond_with :location => group, :error => message
    end
  end

end
