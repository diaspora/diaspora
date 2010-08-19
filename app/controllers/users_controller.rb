class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  
  def index
    @groups_array = current_user.groups.collect{|x| [x.to_s, x.id]} 

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
    @person = @user.person
    @profile = @user.profile
    @photos = Photo.where(:person_id => @person.id).paginate :page => params[:page], :order => 'created_at DESC'
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
