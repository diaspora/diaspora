class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  def index
    @users = User.sort(:created_at.desc).all
  end
  def show
    @user= User.first(:id => params[:id])
    @user_profile = @user.person.profile
  end

  def edit
    @user = User.first(:id => params[:id])
    @profile = @user.profile
    @photos = Photo.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def update
    @user = User.where(:id => params[:id]).first
    
    if @user.update_profile(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def create
    @user = User.new(params[:user])

    if @user.person.save! && @user.save! 
      flash[:notice] = "Successfully signed up."
      redirect_to root_path
    else
      render :action => 'new'
    end
  end

  def new
    @user = User.new
  end
  
end
