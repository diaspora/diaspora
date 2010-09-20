#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class UsersController < ApplicationController
  include UsersHelper
  
  before_filter :authenticate_user!, :except => [:new, :create]

  respond_to :html

  def edit
    @user    = current_user
    @person  = @user.person
    @profile = @user.profile
    @photos  = Photo.find_all_by_person_id(@person.id).paginate :page => params[:page], :order => 'created_at DESC'
  end

  def update
    @user = current_user
    prep_image_url(params[:user])

    @user.update_profile params[:user]
    respond_with(@user, :location => root_url)
  end
end
