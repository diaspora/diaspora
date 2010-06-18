class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!
  include StatusMessagesHelper

  def index
    @status_messages = StatusMessage.criteria.all.order_by( [:created_at, :desc] )
    @friends = Friend.all

    respond_to do |format|
      format.html 
      format.xml {render :xml => StatusMessages.new(@status_messages).to_xml }
      format.json { render :json => @status_messages }
    end

  end
  
  def create
    @status_message = StatusMessage.new(params[:status_message])
    if @status_message.save
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
    @status_message = StatusMessage.first(:conditions => {:id => params[:id]})
    @status_message.destroy
    flash[:notice] = "Successfully destroyed status message."
    redirect_to status_messages_url
  end
  
  def show
    @status_message = StatusMessage.first(:conditions => {:id => params[:id]})
    
    respond_to do |format|
      format.html 
      format.xml { render :xml => @status_message }
      format.json { render :json => @status_message }
    end
  end
end
