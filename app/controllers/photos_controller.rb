# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_action :authenticate_user!, except: %i(show index)
  respond_to :html, :json

  def show
    @photo = if user_signed_in?
      current_user.photos_from(Person.find_by_guid(params[:person_id])).where(id: params[:id]).first
    else
      Photo.where(id: params[:id], public: true).first
    end

    raise ActiveRecord::RecordNotFound unless @photo
  end

  def index
    @post_type = :photos
    @person = Person.find_by_guid(params[:person_id])
    authenticate_user! if @person.try(:remote?) && !user_signed_in?
    @presenter = PersonPresenter.new(@person, current_user)

    if @person
      @contact = current_user.contact_for(@person) if user_signed_in?
      @posts = Photo.visible(current_user, @person, :all, max_time)
      respond_to do |format|
        format.all do
          gon.preloads[:person] = @presenter.as_json
          gon.preloads[:photos_count] = Photo.visible(current_user, @person).count(:all)
          render "people/show", layout: "with_header"
        end
        format.mobile { render "people/show" }
        format.json{ render_for_api :backbone, :json => @posts, :root => :photos }
      end
    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def create
    rescuing_photo_errors do
      legacy_create
    end
  end

  def make_profile_photo
    author_id = current_user.person_id
    @photo = Photo.where(:id => params[:photo_id], :author_id => author_id).first

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
                                       :author_id => author_id},
                            :status => 201}
        end
      else
        head :unprocessable_entity
      end
    else
      head :unprocessable_entity
    end
  end

  def destroy
    photo = current_user.photos.where(:id => params[:id]).first

    if photo
      current_user.retract(photo)

      respond_to do |format|
        format.json { head :no_content }
        format.html do
          flash[:notice] = I18n.t 'photos.destroy.notice'
          if StatusMessage.find_by_guid(photo.status_message_guid)
              respond_with photo, :location => post_path(photo.status_message)
          else
            respond_with photo, :location => person_photos_path(current_user.person)
          end
        end
      end
    else
      respond_with photo, :location => person_photos_path(current_user.person)
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:public, :text, :pending, :user_file, :image_url, :aspect_ids, :set_profile_photo)
  end

  def file_handler(params)
    # For XHR file uploads, request.params[:qqfile] will be the path to the temporary file
    # For regular form uploads (such as those made by Opera), request.params[:qqfile] will be an UploadedFile which can be returned unaltered.
    if not request.params[:qqfile].is_a?(String)
      params[:qqfile]
    else
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create tempora##l file
      file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
      # put data into this file from raw post request
      file.print request.raw_post.force_encoding('BINARY')

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      file
    end
  end

  def legacy_create
    photo_params = params.require(:photo).permit(:pending, :set_profile_photo, aspect_ids: [])
    if photo_params[:aspect_ids] == "all"
      photo_params[:aspect_ids] = current_user.aspects.map(&:id)
    elsif photo_params[:aspect_ids].is_a?(Hash)
      photo_params[:aspect_ids] = params[:photo][:aspect_ids].values
    end

    photo_params[:user_file] = file_handler(params)

    @photo = current_user.build_post(:photo, photo_params)

    if @photo.save

      unless @photo.pending
        unless @photo.public?
          aspects = current_user.aspects_from_ids(photo_params[:aspect_ids])
          current_user.add_to_streams(@photo, aspects)
        end
        current_user.dispatch_post(@photo, to: photo_params[:aspect_ids])
      end

      current_user.update_profile(photo: @photo) if photo_params[:set_profile_photo]

      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        format.html{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
      end
    else
      respond_with @photo, :location => photos_path, :error => message
    end
  end

  def rescuing_photo_errors
    begin
      yield
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
end
