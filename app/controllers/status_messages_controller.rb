class StatusMessagesController < ApplicationController
  #before_filter :authenticate_user!

  def index
    @status_messages = StatusMessage.paginate :page => params[:page], :order => 'created_at DESC'
    

    respond_to do |format|
      format.html 
      format.atom {render :xml => Diaspora::OStatus::generate(:current_url => request.url, :objects => @status_messages)}
    end

  end
  
  def create
    @status_message = current_user.post(:status_message, params[:status_message])
    
    if @status_message.created_at
      flash[:notice] = "Successfully created status message."
      redirect_to status_messages_url
    else
      render :action => 'new'
    end
  end
  
  def new
    @status_message = StatusMessage.new
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
      format.xml { render :xml => Post.build_xml_for(@status_message) }
      format.json { render :json => @status_message }
    end
  end
end
