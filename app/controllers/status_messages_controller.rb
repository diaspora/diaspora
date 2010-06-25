class StatusMessagesController < ApplicationController

  def index
    @status_message = StatusMessage.new
    @status_messages = StatusMessage.criteria.all.order_by( [:created_at, :desc] )
    

    respond_to do |format|
      format.html 
      format.xml {render :xml => Post.build_xml_for(@status_messages)}
      format.json { render :json => @status_messages }
    end

  end
  
  def create
    if current_user.post :status_message, params[:status_message]
      flash[:notice] = "Successfully created status message."
      redirect_to status_messages_url
    else
      flash[:notics] = "You have failed to update your status."
      render :action => 'new'
    end
  end
  
  def new
    @status_message = StatusMessage.new
  end
  
  def destroy
    @status_message = StatusMessage.first(:conditions => {:id => params[:id]})
    @status_message.destroy
    flash[:notice] = "Successfully destroyed status message."
    redirect_to status_messages_url
  end
  
  def show
    @status_message = StatusMessage.first(:conditions => {:id => params[:id]})
    
    respond_to do |format|
      format.html 
      format.xml { render :xml => Post.build_xml_for(@status_message) }
      format.json { render :json => @status_message }
    end
  end
end
