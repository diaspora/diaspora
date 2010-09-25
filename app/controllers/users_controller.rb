#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
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

    data = clean_hash params[:user]
    prep_image_url(data)

    @user.update_profile data
    respond_with(@user, :location => root_url)
  end

  private
  def prep_image_url(params)
    if params[:profile][:image_url].empty?
      params[:profile].delete(:image_url)
    else
      url = APP_CONFIG[:pod_url].chop if APP_CONFIG[:pod_url][-1,1] == '/'
      params[:profile][:image_url] = url + params[:profile][:image_url]
    end
  end

  def clean_hash(params)
    return {
      :profile =>
        {
        :first_name => params[:profile][:first_name],
        :last_name => params[:profile][:last_name],
        :image_url => params[:profile][:image_url]
        }
    }
  end

end
