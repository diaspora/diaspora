#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


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
      message = I18n.t 'photos.create.type_error'
      respond_with :location => album, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with :location => album, :error => message

    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
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
    flash[:notice] = I18n.t 'photos.destroy.notice'
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

    redirect_to @photo unless current_user.owns? @album
  end

  def update
    @photo = Photo.find_by_id params[:id]
    if @photo.update_attributes params[:photo]
      flash[:notice] = I18n.t 'photos.update.notice'
      respond_with @photo
    else
      flash[:error] = I18n.t 'photos.update.error'
      render :action => :edit
    end
  end
end
