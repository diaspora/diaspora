class PhotosController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show
  
  def create
    
    album = Album.find_by_id params[:album_id]

    begin
      @photo = current_user.post(:photo, params)
      respond_with @photo
      
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
