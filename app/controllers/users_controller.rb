class UsersController < ApplicationController

  before_filter :authenticate_user!
  def index
    @users = User.sort(:created_at.desc).all
  end
  def show
    @user= Person.where(:id => params[:id]).first
    @user_profile = @user.profile
  end
end
