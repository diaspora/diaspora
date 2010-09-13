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


class AlbumsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @albums = Album.mine_or_friends(params[:friends], current_user).paginate :page => params[:page], :order => 'created_at DESC'
    respond_with @albums
  end
  
  def create
    @album = current_user.post(:album, params[:album])
    respond_with @album, :notice => "You've created an album called #{@album.name}."
  end
  
  def new
    @album = Album.new
  end
  
  def destroy
    @album = Album.find_by_id params[:id]
    @album.destroy
    respond_with :location => albums_url, :notice => "Album #{@album.name} destroyed."
  end
  
  def show
    @photo = Photo.new
    @album = Album.find_by_id params[:id]
    @album_photos = @album.photos

    respond_with @album
  end

  def edit
    @album = Album.find_by_id params[:id]
    redirect_to @album unless current_user.owns? @album
  end

  def update
    @album = Album.find_params_by_id params[:id]
    respond_with @album, :notice => "Album #{@album.name} successfully edited."
  end

end
