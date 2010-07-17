class PhotosController < ApplicationController
  #before_filter :authenticate_user!

  def index
    @photos = Photo.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def create
    @photo = Photo.new(params[:photo])
    
    if @photo.save
      flash[:notice] = "Successfully uploaded photo."
      redirect_to photos_url
    else
      render :action => 'new'
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
  end
end
