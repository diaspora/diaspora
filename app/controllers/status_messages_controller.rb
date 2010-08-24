class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    params[:status_message][:group_ids] = params[:group_ids]
    @status_message = current_user.post(:status_message, params[:status_message])
    
    if @status_message.created_at
      render :nothing => true
    else
      redirect_to root_url
    end
  end
  
  def destroy
    @status_message = StatusMessage.where(:id => params[:id]).first
    @status_message.destroy
    flash[:notice] = "Successfully destroyed status message."
    redirect_to root_url
  end
  
  def show
    @status_message = StatusMessage.where(:id => params[:id]).first
    
    respond_to do |format|
      format.html 
      format.xml { render :xml => @status_message.build_xml_for }
      format.json { render :json => @status_message }
    end
  end
end
