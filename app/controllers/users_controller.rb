#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  respond_to :html
  respond_to :json, :only => :show

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
