#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  before_filter :remove_getting_started, :only => [:create]

  respond_to :html,
             :mobile,
             :json

  # Called when a user clicks "Mention" on a profile page
  # @param person_id [Integer] The id of the person to be mentioned
  def new
    if params[:person_id] && @person = Person.where(:id => params[:person_id]).first
      @aspect = :profile
      @contact = current_user.contact_for(@person)
      @aspects_with_person = []
      if @contact
        @aspects_with_person = @contact.aspects
        @aspect_ids = @aspects_with_person.map{|x| x.id}
        @contacts_of_contact = @contact.contacts
        render :layout => nil
      end
    else
      @aspect = :all
      @aspects = current_user.aspects
      @aspect_ids = @aspects.map{ |a| a.id }
    end
  end

  def bookmarklet
    @aspects = current_user.aspects
    @selected_contacts = @aspects.map { |aspect| aspect.contacts }.flatten.uniq
    @aspect_ids = @aspects.map{|x| x.id}
    if ! is_mobile_device?
      render :layout => nil
    end
  end

  def create
    params[:status_message][:aspect_ids] = [*params[:aspect_ids]]
    normalize_public_flag!

    @status_message = current_user.build_post(:status_message, params[:status_message])

    photos = Photo.where(:id => [*params[:photos]], :diaspora_handle => current_user.person.diaspora_handle)
    unless photos.empty?
      @status_message.photos << photos
    end

    if @status_message.save
      # always send to all aspects if public
      if params[:status_message][:public] || params[:status_message][:aspect_ids].first == "all_aspects"
        aspect_ids = current_user.aspects.map{|a| a.id}
      else
        aspect_ids = params[:aspect_ids]
      end

      aspects = current_user.aspects_from_ids(aspect_ids)
      current_user.add_to_streams(@status_message, aspects)
      receiving_services = current_user.services.where(:type => params[:services].map{|s| "Services::"+s.titleize}) if params[:services]
      current_user.dispatch_post(@status_message, :url => short_post_url(@status_message.guid), :services => receiving_services)

      if request.env['HTTP_REFERER'].include?("people") # if this is a post coming from a profile page
        flash[:notice] = t('status_messages.create.success', :names => @status_message.mentions.includes(:person => :profile).map{ |mention| mention.person.name }.join(', '))
      end

      respond_to do |format|
        format.html { redirect_to :back}
        format.mobile{ redirect_to multi_stream_path}
        format.json{ render :json => @status_message.as_api_response(:backbone), :status => 201 }
      end
    else
      unless photos.empty?
        photos.update_all(:status_message_guid => nil)
      end

      respond_to do |format|
        format.json { render :nothing, :status => 403 }
        format.html { redirect_to :back }
      end
    end
  end

  def normalize_public_flag!
    # mobile || desktop conditions
    public_flag = (params[:status_message][:aspect_ids] && params[:status_message][:aspect_ids].first == 'public') || params[:status_message][:public]
    public_flag.to_s.match(/(true)|(on)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag
    public_flag
  end

  helper_method :comments_expanded
  def comments_expanded
    true
  end

  def remove_getting_started
    if current_user.getting_started == true
      current_user.update_attributes(:getting_started => false)
    end
    true
  end
end
