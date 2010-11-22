#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    @aspect = :profile
    @post_type = :photos
    @person = Person.find_by_id(params[:person_id])

    if @person
      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @is_contact = @person != current_user.person && @contact

      if @contact
        @aspects_with_person = @contact.aspects
      else
        @pending_request = current_user.pending_requests.find_by_person_id(@person.id)
      end

      @posts = current_user.raw_visible_posts.all(:_type => 'Photo', :person_id => @person.id, :order => 'created_at DESC').paginate :page => params[:page], :order => 'created_at DESC'

      render 'people/show'

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def create
    begin
      params[:photo][:user_file] = file_handler(params)

      @photo = current_user.build_post(:photo, params[:photo])

      if @photo.save
        raise 'MongoMapper failed to catch a failed save' unless @photo.id

        current_user.dispatch_post(@photo, :to => params[:photo][:to]) unless @photo.pending
        respond_to do |format|
          format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        end
      else
        respond_with :location => photos_path, :error => message
      end

    rescue TypeError
      message = I18n.t 'photos.create.type_error'
      respond_with :location => photos_path, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with :location => photos_path, :error => message

    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
      respond_with :location => photos_path, :error => message
      raise e
    end
  end

  def new
    @photo = Photo.new
    respond_with @photo
  end

  def destroy
    photo = current_user.my_posts.where(:_id => params[:id]).first

    if photo
      photo.destroy
      flash[:notice] = I18n.t 'photos.destroy.notice'
    end

    respond_with :location => photos_path
  end

  def show
    @aspect = :none
    @photo = current_user.find_visible_post_by_id params[:id]
    unless @photo
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @ownership = current_user.owns? @photo

      respond_with @photo
    end
  end

  def edit
    if @photo = current_user.my_posts.where(:_id => params[:id]).first
      respond_with @photo
    else
      redirect_to person_photos_path(current_user.person)
    end
  end

  def update
    photo = current_user.my_posts.where(:_id => params[:id]).first
    if photo
      if current_user.update_post( photo, params[:photo] )
        flash[:notice] = I18n.t 'photos.update.notice'
        respond_with photo
      else
        flash[:error] = I18n.t 'photos.update.error'
        redirect_to [:edit, photo]
      end
    else
      redirect_to person_photos_path(current_user.person)
    end
  end


  private 

  def file_handler(params)
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create tempora##l file
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
      file
  end
end
