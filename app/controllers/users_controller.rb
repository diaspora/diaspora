#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  respond_to :html
  respond_to :json, :only => :show

  def show
    @user         = User.find_by_id params[:id]
    @user_profile = @user.person.profile
    @person = @current_user
    @posts = current_user.raw_visible_posts.paginate :page => params[:page], :order => 'created_at DESC'
    respond_with @person
  end

  def edit
    @user    = current_user
    @person  = @user.person
    @profile = @user.profile
    @photos  = Photo.find_all_by_person_id(@person.id).paginate :page => params[:page], :order => 'created_at DESC'
  end

  def update
    @user = User.find_by_id params[:id]
    prep_image_url(params[:user])

    @user.update_profile params[:user]
    respond_with(@user, :location => root_url)
  end

  private

  def prep_image_url(params)
    if params[:profile][:image_url].empty?
      params[:profile].delete(:image_url)
    else
      params[:profile][:image_url] = "http://" + request.host + ":" + request.port.to_s + params[:profile][:image_url]
    end
  end
end
