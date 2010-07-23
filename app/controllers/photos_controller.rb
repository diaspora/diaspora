class PhotosController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    #begin
      @photo = Photo.instantiate(params[:photo])
      @photo.person = current_user




      if @photo.save
        flash[:notice] = "Successfully uploaded photo."
        redirect_to @photo.album
      else
        render :action => 'album#new'
      end

    #rescue
    #  flash[:error] = "Photo upload failed.  Are you sure that was an image?"
    #  redirect_to Album.first(:id => params[:photo][:album_id])
    #end
  end
  
  def new
    @photo = Photo.new
  end
  
  def destroy
    @photo = Photo.where(:id => params[:id]).first
    @photo.destroy
    flash[:notice] = "Successfully deleted photo."
    redirect_to root_url
  end
  
  def show
    @photo = Photo.where(:id => params[:id]).first
    @album = @photo.album
  end
end
