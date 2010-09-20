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

      data = clean_hash(params)


      @photo = current_user.post(:photo, data)

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
    @photo = current_user.find_visible_post_by_id params[:id]

    @photo.destroy
    flash[:notice] = "Photo deleted."
    respond_with :location => @photo.album
  end

  def show
    @photo = current_user.find_visible_post_by_id params[:id]
    @album = @photo.album
    respond_with @photo, @album
  end

  def edit
    @photo = current_user.find_visible_post_by_id params[:id]
    @album = @photo.album

    redirect_to @photo unless current_user.owns? @album
  end

  def update
    @photo = current_user.find_visible_post_by_id params[:id]

    data = clean_hash(params)

    if @photo.update_attributes data[:photo]
      flash[:notice] = "Photo successfully updated."
      respond_with @photo
    else
      flash[:error] = "Failed to edit photo."
      render :action => :edit
    end
  end


  private
  def clean_hash(params)
    return {
      :photo => {
        :caption   => params[:photo][:caption],
      },
      :album_id  => params[:album_id],
      :user_file => params[:user_file]
    }
  end

end
