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
    
    #only do it if it is an email address
    if params[:q].try(:match, Devise.email_regexp)
      webfinger(params[:q])
    end
    
    if @people.count == 1
      redirect_to @people.first
    else
      respond_with @people
    end
  end

  def show
    @person = Person.find(params[:id].to_id)
    @post_type = :all
    @aspect = :none 
    if @person
      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @is_contact = @person != current_user.person && @contact

      if @contact
        @aspects_with_person = @contact.aspects
      end

      @posts = current_user.visible_posts(:person_id => @person.id, :_type => "StatusMessage").paginate :page => params[:page], :order => 'created_at DESC'
      respond_with @person, :locals => {:post_type => :all}

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def destroy
    current_user.disconnect(current_user.visible_person_by_id(params[:id]))
    respond_with :location => root_url
  end

  def edit
    @aspect  = :person_edit
    @person  = current_user.person
    @profile = @person.profile
  end

  def update
    # convert date selector into proper timestamp
    
    if birthday = params[:date]
      unless [:month, :day, :year].any?{|x| birthday[x].blank?} 
        params[:person][:profile][:birthday] ||= Date.parse("#{birthday[:year]}-#{birthday[:month]}-#{birthday[:day]}")
      end
    end

    # upload and set new profile photo
    params[:person][:profile] ||= {}
    if params[:person][:profile][:image].present?
      raw_image = params[:person][:profile].delete(:image)
      params[:profile_image_hash] = { :user_file => raw_image, :to => "all" }

      photo = current_user.post(:photo, params[:profile_image_hash])
      params[:person][:profile][:image_url] = photo.url(:thumb_large)
    end

    if current_user.update_profile params[:person][:profile]
      flash[:notice] = I18n.t 'people.update.updated'
    else
      flash[:error] = I18n.t 'people.update.failed'
    end

    if params[:getting_started]
      redirect_to getting_started_path(:step => params[:getting_started].to_i+1)
    else
      redirect_to edit_person_path
    end
  end

  def retrieve_remote
    if params[:diaspora_handle]
      webfinger(params[:diaspora_handle], :single_aspect_form => true)
      render :nothing => true
    else
      render :nothing => true, :status => 422
    end
  end

  private
  def webfinger(account, opts = {})
    finger = EMWebfinger.new(account)
    finger.on_person do |response|
      if response.class == Person
        response.socket_to_uid(current_user.id, opts)
      else
        require File.join(Rails.root,'lib/diaspora/websocket')
        Diaspora::WebSocket.queue_to_user(current_user.id, {:class => 'people', :status => 'fail', :query => account, :response => response}.to_json)
      end
    end
  end
end
