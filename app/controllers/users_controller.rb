class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def show
    @user         = User.find_by_id params[:id]
    @user_profile = @user.person.profile

    respond_with @user
  end

  def edit
    @user    = current_user
    @person  = @user.person
    @profile = @user.profile
    @photos  = Photo.find_all_by_person_id(@person.id).paginate :page => params[:page], :order => 'created_at DESC'
  end

  def update
    @user = User.find_by_id params[:id]
    @user.update_profile params[:user]
    respond_with @user
  end
end 
