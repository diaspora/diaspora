class UsersController < ApplicationController

  before_filter :authenticate_user!
  def index
    @users = User.sort(:created_at.desc).all
  end

  def show
    @user = User.find(params[:id])
  end
end
