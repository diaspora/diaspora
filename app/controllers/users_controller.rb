class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  def index
    unless params[:q]
      @people = Person.all
      render :index
    else
      @people = Person.search(params[:q])
    end  
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
      flash[:notice] = "Successfully updated your profile"
      redirect_to @user.person
    else
      render :action => 'edit'
    end
  end
  

  
end
