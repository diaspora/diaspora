class PhotosController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    begin
      @photo = current_user.post(:photo, params)
      render :nothing => true if @photo.created_at
      
    rescue TypeError
      flash[:error] = "Photo upload failed. Are you sure an image was added?"
      redirect_to Album.first(:id => params[:album_id])
    rescue CarrierWave::IntegrityError
      flash[:error] = "Photo upload failed.  Are you sure that was an image?"
      redirect_to Album.first(:id => params[:album_id])
    rescue RuntimeError => e
      flash[:error] = "Photo upload failed.  Are you sure that your seatbelt is fastened?"
      redirect_to Album.first(:id => params[:album_id])
      raise e
    end
  end
  
  def new
    @photo = Photo.new
    @album = current_user.album_by_id(params[:album_id])
    render :partial => "new_photo"
  end
  
  def destroy
    @photo = Photo.first(:id => params[:id])
    @photo.destroy
    flash[:notice] = "Successfully deleted photo."
    redirect_to @photo.album
  end
  
  def show
    @photo = Photo.first(:id => params[:id])
    @album = @photo.album
  end

  def edit
    @photo= Photo.first(:id => params[:id])
    @album = @photo.album
  end

  def update
    @photo= Photo.first(:id => params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Successfully updated photo."
      redirect_to @photo
    else
      render :action => 'edit'
    end
  end
end
