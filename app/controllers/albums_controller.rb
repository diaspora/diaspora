#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
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
    aspect = params[:album][:to]

    data = clean_hash(params[:album])

    @album = current_user.post(:album, data)
    flash[:notice] = I18n.t 'albums.create.success', :name  => @album.name
    redirect_to :action => :show, :id => @album.id, :aspect => aspect
  end

  def new
    @album = Album.new
  end

  def destroy
    @album = current_user.find_visible_post_by_id params[:id]
    @album.destroy
    flash[:notice] =  I18n.t 'albums.destroy.success', :name  => @album.name
    respond_with :location => albums_url
  end

  def show
    @photo = Photo.new
    @album = current_user.find_visible_post_by_id( params[:id] )
    @album_photos = @album.photos
    respond_with @album
  end

  def edit
    @album = current_user.find_visible_post_by_id params[:id]
    redirect_to @album unless current_user.owns? @album
  end

  def update
    @album = current_user.find_visible_post_by_id params[:id]

    data = clean_hash(params[:album])

    if current_user.update_post( @album, data )
      flash[:notice] =  I18n.t 'albums.update.success', :name  => @album.name
      respond_with @album
    else
      flash[:error] =  I18n.t 'albums.update.failure', :name  => @album.name
      render :action => :edit
    end
  end

  private
  def clean_hash(params)
    return {
      :name => params[:name],
      :to   => params[:to]
    }
  end
end
