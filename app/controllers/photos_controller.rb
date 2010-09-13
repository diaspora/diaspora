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


class PhotosController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show
  
  def create
    
    album = Album.find_by_id params[:album_id]

    begin

      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create temporal file
      file = Tempfile.new(file_name)
      # put data into this file from raw post request
      file.print request.raw_post

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}

      ##############
    

      params[:user_file] = file 
      @photo = current_user.post(:photo, params)

      respond_to do |format|
        format.json{render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
      end
      
    rescue TypeError
      message = "Photo upload failed.  Are you sure an image was added?"
      respond_with :location => album, :error => message

    rescue CarrierWave::IntegrityError
      message = "Photo upload failed.  Are you sure that was an image?"
      respond_with :location => album, :error => message

    rescue RuntimeError => e
      message = "Photo upload failed.  Are you sure that your seatbelt is fastened?"
      respond_with :location => album, :error => message
      raise e
    end
  end
  
  def new
    @photo = Photo.new
    @album = current_user.album_by_id(params[:album_id])
    render :partial => 'new_photo'
  end
  
  def destroy
    @photo = Photo.find_by_id params[:id]
    @photo.destroy
    respond_with :location => @photo.album
  end
  
  def show
    @photo = Photo.find_by_id params[:id]
    @album = @photo.album

    respond_with @photo, @album
  end

  def edit
    @photo = Photo.find_by_id params[:id]
    @album = @photo.album
  end

  def update
    @photo = Photo.find_by_id params[:id]
    @photo.update_attributes params[:photo]

    respond_with @photo
  end
end
