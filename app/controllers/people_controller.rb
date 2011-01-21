#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspect = :search
    params[:q] ||= params[:term]

    @people = Person.search(params[:q], current_user).paginate :page => params[:page], :per_page => 15
    @hashes = hashes_for_people(@people, @aspects)
    #only do it if it is an email address
    if params[:q].try(:match, Devise.email_regexp)
      webfinger(params[:q])
    end
    respond_with @people
  end

  def hashes_for_people people, aspects
    ids = people.map{|p| p.id}
    requests = {}
    Request.where(:sender_id => ids, :recipient_id => current_user.person.id).each do |r|
      requests[r.id] = r
    end
    contacts = {}
    Contact.where(:user_id => current_user.id, :person_id => ids).each do |contact|
      contacts[contact.person_id] = contact
    end

    people.map{|p|
      {:person => p,
        :contact => contacts[p.id],
        :request => requests[p.id],
        :aspects => aspects}
    }
  end

  def show
    @person = Person.where(:id => params[:id]).first
    @post_type = :all
    @share_with = (params[:share_with] == 'true')

    if @person
      @incoming_request = current_user.request_from(@person)

      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @aspects_with_person = []

      if @contact
        @aspects_with_person = @contact.aspects
        @contacts_of_contact = @contact.contacts
      end

      if (@person != current_user.person) && (!@contact || @contact.pending)
        @commenting_disabled = true
      else
        @commenting_disabled = false
      end

      @posts = current_user.posts_from(@person).where(:type => "StatusMessage").paginate  :per_page => 15, :page => params[:page]
      @fakes = PostsFake.new(@posts)

      respond_with @person, :locals => {:post_type => :all}

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def destroy
    current_user.disconnect(Person.where(:id => params[:id]).first)
    redirect_to root_url
  end

  def edit
    @aspect  = :person_edit
    @person  = current_user.person
    @profile = @person.profile
  end

  def update
    # upload and set new profile photo
    params[:profile] ||= {}
    params[:profile][:searchable] ||= false
    params[:profile][:photo] = Photo.where(:person_id => current_user.person.id,
                                           :id => params[:photo_id]).first if params[:photo_id]

    if current_user.update_profile params[:profile]
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

  def share_with
    @person = Person.find(params[:id])
    @contact = current_user.contact_for(@person)
    @aspects_with_person = []

    if @contact
      @aspects_with_person = @contact.aspects
    end

    @aspects_without_person = @all_aspects.reject do |aspect|
      @aspects_with_person.include?(aspect)
    end

    render :layout => nil
  end

  private
  def webfinger(account, opts = {})
    Resque.enqueue(Job::SocketWebfinger, current_user.id, account, opts)
  end
end
