class PersonRequestsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @person_requests = PersonRequest.paginate :page => params[:page], :order => 'created_at DESC'
    @person_request = PersonRequest.new
    @person = Person.new
  end
  
  def show
    @person_request = PersonRequest.where(:id => params[:id]).first
  end
  
  def destroy
    @person_request = PersonRequest.where(:id => params[:id]).first
    @person_request.destroy
    flash[:notice] = "Successfully destroyed person request."
    redirect_to person_requests_url
  end
  
  def new
    @person_request = PersonRequest.new
    @recipient = Person.new
  end
  
  def create
    @person_request = PersonRequest.for(params[:person_request][:url])

    if @person_request
      flash[:notice] = "Successfully created person request."
      redirect_to @person_request
    else
      render :action => 'new'
    end
  end
end
