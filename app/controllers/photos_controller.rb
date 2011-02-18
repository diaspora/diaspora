#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    @post_type = :photos
    @person = Person.find_by_id(params[:person_id])

    if @person
      @incoming_request = Request.where(:recipient_id => current_user.person.id, :sender_id => @person.id).first
      @outgoing_request = Request.where(:sender_id => current_user.person.id, :recipient_id => @person.id).first

      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @is_contact = @person != current_user.person && @contact
      @aspects_with_person = []

      if @contact
        @aspects_with_person = @contact.aspects
        @contacts_of_contact = @contact.contacts
      else
        @contact = Contact.new
        @contacts_of_contact = []
      end

      @posts = current_user.visible_photos.where(
        :person_id => @person.id
      ).paginate(:page => params[:page])

      render 'people/show'

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def create
    begin
      raise unless params[:photo][:aspect_ids]

      if params[:photo][:aspect_ids] == "all"
        params[:photo][:aspect_ids] = current_user.aspects.collect{|x| x.id}
      elsif params[:photo][:aspect_ids].is_a?(Hash)
        params[:photo][:aspect_ids] = params[:photo][:aspect_ids].values
      end

      params[:photo][:user_file] = file_handler(params)

      @photo = current_user.build_post(:photo, params[:photo])

      if @photo.save
        raise 'MongoMapper failed to catch a failed save' unless @photo.id


        aspects = current_user.aspects_from_ids(params[:photo][:aspect_ids])

        unless @photo.pending
          current_user.add_to_streams(@photo, aspects)
          current_user.dispatch_post(@photo, :to => params[:photo][:aspect_ids])
        end

        if params[:photo][:set_profile_photo]
          profile_params = {:image_url => @photo.url(:thumb_large),
                           :image_url_medium => @photo.url(:thumb_medium),
                           :image_url_small => @photo.url(:thumb_small)}
          current_user.update_profile(profile_params)
        end

        respond_to do |format|
          format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        end
      else
        respond_with @photo, :location => photos_path, :error => message
      end

    rescue TypeError
      message = I18n.t 'photos.create.type_error'
      respond_with @photo, :location => photos_path, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with @photo, :location => photos_path, :error => message

    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
      respond_with @photo, :location => photos_path, :error => message
      raise e
    end
  end

  def make_profile_photo
    person_id = current_user.person.id
    @photo = Photo.where(:id => params[:photo_id], :person_id => person_id).first

    if @photo
      profile_hash = {:image_url        => @photo.url(:thumb_large),
                      :image_url_medium => @photo.url(:thumb_medium),
                      :image_url_small  => @photo.url(:thumb_small)}

      if current_user.update_profile(profile_hash)
        respond_to do |format|
          format.js{ render :json => { :photo_id  => @photo.id,
                                       :image_url => @photo.url(:thumb_large),
                                       :image_url_medium => @photo.url(:thumb_medium),
                                       :image_url_small  => @photo.url(:thumb_small),
                                       :person_id => person_id},
                            :status => 201}
        end
      else
        render :nothing => true, :status => 406
      end
    else
      render :nothing => true, :status => 406
    end
  end

  def destroy
    photo = current_user.posts.where(:id => params[:id]).first

    if photo
      photo.destroy
      flash[:notice] = I18n.t 'photos.destroy.notice'


      if photo.status_message_id
        respond_with photo, :location => photo.status_message
      else
        respond_with photo, :location => person_photos_path(current_user.person)
      end
    else
      respond_with photo, :location => person_photos_path(current_user.person)
    end

  end

  def show
    @photo = current_user.visible_photos.where(:id => params[:id]).includes(:person, :status_message => :photos).first
    @photo ||= Photo.where(:public => true, :id => params[:id]).includes(:person, :status_message => :photos).first
    if @photo
      @parent = @photo.status_message

      #if photo is not an attachment, fetch comments for self
      if @parent
        @additional_photos = @photo.status_message.photos
        if @additional_photos
          @next_photo = @additional_photos[@additional_photos.index(@photo)+1]
          @prev_photo = @additional_photos[@additional_photos.index(@photo)-1]
          @next_photo ||= @additional_photos.first
        end
      else
        @parent = @photo
      end

      @object_aspect_ids = []
      if @parent_aspects = @parent.aspects.where(:user_id => current_user.id)
        @object_aspect_ids = @parent_aspects.map{|a| a.id}
      end

      @ownership = current_user.owns? @photo

      respond_with @photo
    else
      begin
        redirect_to :back
      rescue
        redirect_to aspects_path
      end
    end

  end

  def edit
    if @photo = current_user.posts.where(:id => params[:id]).first
      respond_with @photo
    else
      redirect_to person_photos_path(current_user.person)
    end
  end

  def update
    photo = current_user.posts.where(:id => params[:id]).first
    if photo
      if current_user.update_post( photo, params[:photo] )
        flash.now[:notice] = I18n.t 'photos.update.notice'
        respond_to do |format|
          format.js{ render :json => photo, :status => 200 }
        end
      else
        flash.now[:error] = I18n.t 'photos.update.error'
        respond_to do |format|
          format.html{ redirect_to [:edit, photo] }
          format.js{ render :status => 403 }
        end
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
