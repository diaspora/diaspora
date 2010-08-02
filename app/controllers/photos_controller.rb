class PhotosController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    begin
      @photo = current_user.post(:photo, params)

      if @photo.created_at
        flash[:notice] = "Successfully uploaded photo."
        redirect_to @photo.album
      else
        render :action => 'album#new'
      end
    rescue TypeError
      flash[:error] = "Photo upload failed. Are you sure an image was added?"
      redirect_to Album.first(:id => params[:photo][:album_id])
    rescue CarrierWave::IntegrityError || 
      flash[:error] = "Photo upload failed.  Are you sure that was an image?"
      redirect_to Album.first(:id => params[:photo][:album_id])
    end
  end
  
  def new
    @photo = Photo.new
  end
  
  def destroy
    @photo = Photo.where(:id => params[:id]).first
    @photo.destroy
    flash[:notice] = "Successfully deleted photo."
    redirect_to @photo.album
  end
  
  def show
    @photo = Photo.where(:id => params[:id]).first
    @album = @photo.album
  end
end
