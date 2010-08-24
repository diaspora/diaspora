class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 
  def index
    @remote_requests = Request.for_user( current_user )
    @request = Request.new
  end
  
  def destroy
    if params[:accept]

      if params[:group_id]
        @friend = current_user.accept_and_respond( params[:id], params[:group_id])
        
        flash[:notice] = "you are now friends"
        redirect_to current_user.group_by_id(params[:group_id])
      else
        flash[:error] = "please select a group!"
        redirect_to requests_url
      end
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
    begin 
      rel_hash = relationship_flow(params[:request][:destination_url])
    rescue Exception => e
      flash[:error] = "no diaspora seed found with this email!"
      redirect_to current_user.group_by_id(params[:request][:group_id])
      return
    end
    
    Rails.logger.debug("Sending request: #{rel_hash}")
    
    begin
      @request = current_user.send_request(rel_hash, params[:request][:group_id])
    rescue Exception => e
      raise e unless e.message.include? "already friends"
      flash[:notice] = "You are already friends with #{params[:request][:destination_url]}!"
      redirect_to current_user.group_by_id(params[:request][:group_id])
    end

    if @request
      flash[:notice] = "a friend request was sent to #{@request.destination_url}"
      redirect_to current_user.group_by_id(params[:request][:group_id])
    else
      flash[:error] = "Something went horribly wrong..."
      redirect_to current_user.group_by_id(params[:request][:group_id])
    end
  end

end
