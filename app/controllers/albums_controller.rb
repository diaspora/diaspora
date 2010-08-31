class AlbumsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @albums = Album.mine_or_friends(params[:friends], current_user).paginate :page => params[:page], :order => 'created_at DESC'
    respond_with @albums
  end
  
  def create
    @album = current_user.post(:album, params[:album])
    respond_with @album
  end
  
  def new
    @album = Album.new
  end
  
  def destroy
    @album = Album.find_by_id params[:id]
    @album.destroy
    respond_with :location => albums_url
  end
  
  def show
    @photo = Photo.new
    @album = Album.find_by_id params[:id]
    @album_photos = @album.photos

    respond_with @album
  end

  def edit
    @album = Album.find_by_id params[:id]
  end

  def update
    @album = Album.find_params_by_id params[:id]
    respond_with @album
  end

end
