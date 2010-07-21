class AlbumsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @albums = Album.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def create
    @album = Album.new(params[:album])
    @album.person = current_user
    
    if @album.save
      flash[:notice] = "Successfully created album."
      redirect_to @album
    else
      render :action => 'new'
    end
  end
  
  def new
    @album = Album.new
  end
  
  def destroy
    @album = Album.first(:id => params[:id])
    @album.destroy
    flash[:notice] = "Successfully destroyed album."
    redirect_to albums_url
  end
  
  def show
    @photo = Photo.new
    @album = Album.first(:id => params[:id])
    @album_photos = @album.photos
  end
end
