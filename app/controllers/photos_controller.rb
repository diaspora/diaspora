#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    if params[:person_id]
      @person = current_user.contact_for_person_id(params[:person_id]).person
    end
    @person ||= current_user.person

    @photos = current_user.visible_posts(:_type => "Photo", :person_id => @person.id)
    @albums = current_user.visible_posts(:_type => "Album", :person_id => @person.id)

    @aspect = :photos
  end

  def create
    album = current_user.find_visible_post_by_id( params[:photo][:album_id] )

    begin

      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create temporal file
      begin
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print request.raw_post.force_encoding('BINARY')
      rescue RuntimeError => e
        raise e unless e.message.include?('cannot generate tempfile')
        file = Tempfile.new(file_name) # Ruby 1.8 compatibility
        file.print request.raw_post
      end
      # put data into this file from raw post request

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}

      ##############

      params[:photo][:user_file] = file

      @photo = current_user.build_post(:photo, params[:photo])

      if @photo.save
        raise 'MongoMapper failed to catch a failed save' unless post.id
        current_user.dispatch_post(@photo, :to => params[:photo][:to])
        respond_to do |format|
          format.json{render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        end
      else
        respond_with :location => album, :error => message
      end

    rescue TypeError
      message = I18n.t 'photos.create.type_error'
      respond_with :location => album, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with :location => album, :error => message

    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
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
    @photo = current_user.find_visible_post_by_id params[:id]

    @photo.destroy
    flash[:notice] = I18n.t 'photos.destroy.notice'

    redirect = @photo.album
    redirect ||= photos_path

    respond_with :location => @photo.album
  end

  def show
    @photo = current_user.find_visible_post_by_id params[:id]
    unless @photo
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @album = @photo.album
      @ownership = current_user.owns? @photo

      respond_with @photo, @album
    end
  end

  def edit
    @photo = current_user.find_visible_post_by_id params[:id]
    @album = @photo.album 

    redirect_to @photo #unless current_user.owns? @photo
  end

  def update
    @photo = current_user.find_visible_post_by_id params[:id]

    if current_user.update_post( @photo, params[:photo] )
      flash[:notice] = I18n.t 'photos.update.notice'
      respond_with @photo
    else
      flash[:error] = I18n.t 'photos.update.error'
      redirect_to [:edit, @photo]
    end
  end
end
