#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspect = :search
    @people = Person.search(params[:q]).paginate :page => params[:page], :per_page => 25, :order => 'created_at DESC'
    respond_with @people
  end

  def show
    @aspect = :profile
    @person = current_user.visible_person_by_id(params[:id])
    unless @person
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @aspects_with_person = @contact.aspects if @contact
      @posts = current_user.visible_posts(:person_id => @person.id).paginate :page => params[:page], :order => 'created_at DESC'
      respond_with @person
    end
  end

  def destroy
    current_user.unfriend(current_user.visible_person_by_id(params[:id]))
    respond_with :location => root_url
  end

  def edit
    @aspect  = :person_edit
    @person  = current_user.person
    @profile = @person.profile
  end

  def update
    # convert date selector into proper timestamp
    birthday = params[:date]
    if birthday
      params[:person][:profile][:birthday] ||= Date.parse("#{birthday[:year]}-#{birthday[:month]}-#{birthday[:day]}")
    end

    # upload and set new profile photo
    if params[:person][:profile][:image]
      raw_image = params[:person][:profile].delete(:image)
      params[:profile_image_hash] = { :user_file => raw_image, :to => "all" }

      photo = current_user.post(:photo, params[:profile_image_hash])
      params[:person][:profile][:image_url] = photo.url(:thumb_medium)
    end

    prep_image_url(params[:person])

    if current_user.update_profile params[:person][:profile]
      flash[:notice] = "Profile updated"
    else
      flash[:error] = "Failed to update profile"
    end

    if params[:getting_started]
      redirect_to getting_started_path(:step => params[:getting_started].to_i+1)
    else
      redirect_to edit_person_path
    end
  end

  private
  def prep_image_url(params)
    if params[:profile] && params[:profile][:image_url]
      url = APP_CONFIG[:pod_url].dup
      url.chop! if APP_CONFIG[:pod_url][-1,1] == '/'
      if params[:profile][:image_url].empty?
        params[:profile].delete(:image_url)
      else
        if /^http:\/\// =~ params[:profile][:image_url]
          params[:profile][:image_url] = params[:profile][:image_url]
        else
          params[:profile][:image_url] = url + params[:profile][:image_url]
        end
      end
    end
  end

end
