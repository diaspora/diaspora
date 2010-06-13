class UserSessionsController < ApplicationController

  def new
    @user_sessions = UserSession.new
  end
  
  def create
    @user_sessions = UserSession.new(params[:username, :password])
    if @user_sessions.save
      params[:user_logged_in] = params[:username]
      flash[:notice] = "Successfully logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
