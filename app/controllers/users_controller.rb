class UsersController < ApplicationController

  before_filter :authenticate_user!
  def index
    @users = User.sort(:created_at.desc).all
  end
  def show
    @user= Person.first(:id => params[:id])
    @user_profile = @user.profile
  end

  def edit
    @user = User.first(:id => params[:id])
    @profile = @user.profile
  end

  def update
    @user = User.where(:id => params[:id]).first
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end
end
