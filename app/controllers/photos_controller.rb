class PhotosController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @photo = Photo.instantiate(params[:photo])
    @photo.person = current_user

    if @photo.save
      flash[:notice] = "Successfully uploaded photo."
      redirect_to @photo.album
    else
      render :action => 'album#new'
    end
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
