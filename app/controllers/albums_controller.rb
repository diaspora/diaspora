#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class AlbumsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @albums = current_user.albums_by_aspect(@aspect).paginate :page => params[:page], :per_page => 9, :order => 'created_at DESC'
    @aspect = :all
    respond_with @albums, :aspect => @aspect
  end

  def create
    aspect =  params[:album][:to]
    @album = current_user.post(:album, params[:album])
    flash[:notice] = I18n.t('albums.create.success', :name => @album.name)
    redirect_to :action => :show, :id => @album.id, :aspect => aspect
  end

  def new
    @album = Album.new
  end

  def destroy
    @album = Album.find_by_id params[:id]
    @album.destroy
    flash[:notice] = I18n.t('albums.destroy.success', :name => @album.name)
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
    redirect_to @album unless current_user.owns? @album
  end

  def update
    @album = Album.find_params_by_id params[:id]
    if @album.update_attributes params[:album]
      flash[:notice] = I18n.t('albums.update.success', :name => @album.name)
      respond_with @album
    else
      flash[:error] = I18n.t('albums.update.failure', :name => @album.name)
      render :action => :edit
    end
  end

end
