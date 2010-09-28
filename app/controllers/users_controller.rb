#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
  require File.expand_path('../../../lib/diaspora/ostatus_builder', __FILE__)

  before_filter :authenticate_user!, :except => [:new, :create, :public]

  respond_to :html

  def edit
    @user    = current_user
    @person  = @user.person
    @profile = @user.person.profile
    @photos  = Photo.find_all_by_person_id(@person.id).paginate :page => params[:page], :order => 'created_at DESC'

    @fb_access_url = MiniFB.oauth_url(FB_APP_ID, APP_CONFIG[:pod_url] + "services/create",
                                      :scope=>MiniFB.scopes.join(","))
  end

  def update
    @user = current_user

    data = clean_hash params[:user]
    prep_image_url(data)

    @user.update_profile data
    respond_with(@user, :location => root_url)
  end

  def public
    user = User.find_by_username(params[:username])
    director = Diaspora::Director.new
    ostatus_builder = Diaspora::OstatusBuilder.new(user)

    render :xml => director.build(ostatus_builder)
  end

  private
  def prep_image_url(params)
    url = APP_CONFIG[:pod_url].chop if APP_CONFIG[:pod_url][-1,1] == '/'
    if params[:profile][:image_url].empty?
      params[:profile].delete(:image_url)
    else
      if /^http:\/\// =~ params[:profile][:image_url]
        params[:profile][:image_url] = params[:profile][:image_url]
      else
        params[:profile][:image_url] = url + params[:profile][:image_url]
      end
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
