#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  include GonHelper

  before_action :authenticate_user!, except: %i(show stream hovercard)
  before_action :find_person, only: %i(show stream hovercard)
  before_action :authenticate_if_remote_profile!, only: %i(show stream)

  respond_to :html
  respond_to :json, :only => [:index, :show]

  rescue_from ActiveRecord::RecordNotFound do
    render :file => Rails.root.join('public', '404').to_s,
           :format => :html, :layout => false, :status => 404
  end

  rescue_from Diaspora::AccountClosed do
    respond_to do |format|
      format.any { redirect_to :back, :notice => t("people.show.closed_account") }
      format.json { render :nothing => true, :status => 410 } # 410 GONE
    end
  end

  helper_method :search_query

  def index
    @aspect = :search
    limit = params[:limit] ? params[:limit].to_i : 15

    @people = Person.search(search_query, current_user)

    respond_to do |format|
      format.json do
        @people = @people.limit(limit)
        render :json => @people
      end

      format.any(:html, :mobile) do
        #only do it if it is an email address
        if diaspora_id?(search_query)
          @people =  Person.where(:diaspora_handle => search_query.downcase)
          if @people.empty?
            Workers::FetchWebfinger.perform_async(search_query)
            @background_query = search_query.downcase
          end
        end
        @people = @people.paginate(:page => params[:page], :per_page => 15)
        @hashes = hashes_for_people(@people, @aspects)
      end
    end
  end

  def refresh_search
    @aspect = :search
    @people =  Person.where(:diaspora_handle => search_query.downcase)
    @answer_html = ""
    unless @people.empty?
      @hashes = hashes_for_people(@people, @aspects)

      self.formats = self.formats + [:html]
      @answer_html = render_to_string :partial => 'people/person', :locals => @hashes.first
    end
    render :json => { :search_count => @people.count, :search_html => @answer_html }.to_json
  end

  # renders the persons user profile page
  def show
    mark_corresponding_notifications_read if user_signed_in?

    @person_json = PersonPresenter.new(@person, current_user).as_json

    respond_to do |format|
      format.all do
        if user_signed_in?
          @contact = current_user.contact_for(@person)
        end
        gon.preloads[:person] = @person_json
        gon.preloads[:photos_count] = Photo.visible(current_user, @person).count(:all)
        gon.preloads[:contacts_count] = Contact.contact_contacts_for(current_user, @person).count(:all)
        respond_with @person, layout: "with_header"
      end

      format.mobile do
        @post_type = :all
        person_stream
        respond_with @person
      end

      format.json { render json: @person_json }
    end
  end

  def stream
    respond_to do |format|
      format.all { redirect_to person_path(@person) }
      format.json {
        render json: person_stream.stream_posts.map { |p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user)) }
      }
    end
  end

  # hovercards fetch some the persons public profile data via json and display
  # it next to the avatar image in a nice box
  def hovercard
    respond_to do |format|
      format.all do
        redirect_to :action => "show", :id => params[:person_id]
      end

      format.json do
        render json: PersonPresenter.new(@person, current_user).hovercard
      end
    end
  end

  def retrieve_remote
    if params[:diaspora_handle]
      Workers::FetchWebfinger.perform_async(params[:diaspora_handle])
      render :nothing => true
    else
      render :nothing => true, :status => 422
    end
  end

  def contacts
    respond_to do |format|
      format.json { render nothing: true, status: 406 }

      format.any do
        @person = Person.find_by_guid(params[:person_id])

        if @person
          @contact = current_user.contact_for(@person)
          @contacts_of_contact = Contact.contact_contacts_for(current_user, @person)
          gon.preloads[:person] = PersonPresenter.new(@person, current_user).as_json
          gon.preloads[:photos_count] = Photo.visible(current_user, @person).count(:all)
          gon.preloads[:contacts_count] = @contacts_of_contact.count(:all)
          @contacts_of_contact = @contacts_of_contact.paginate(page: params[:page], per_page: (params[:limit] || 15))
          @hashes = hashes_for_people @contacts_of_contact, @aspects
          respond_with @person, layout: "with_header"
        else
          flash[:error] = I18n.t "people.show.does_not_exist"
          redirect_to people_path
        end
      end
    end
  end

  private

  def find_person
    username = params[:username]
    @person = if diaspora_id?(username)
        Person.where({
          diaspora_handle: username.downcase
        }).first
      else
        Person.find_from_guid_or_username({
          id: params[:id] || params[:person_id],
          username: username
        })
      end

    raise ActiveRecord::RecordNotFound if @person.nil?
    raise Diaspora::AccountClosed if @person.closed_account?
  end

  def hashes_for_people(people, aspects)
    people.map {|person|
      {
        person:  person,
        contact: current_user.contact_for(person) || Contact.new(person: person),
        aspects: aspects
      }.tap {|hash|
        gon_load_contact(hash[:contact])
      }
    }
  end

  def search_query
    @search_query ||= params[:q] || params[:term] || ''
  end

  def diaspora_id?(query)
    !(query.nil? || query.lstrip.empty?) && Validation::Rule::DiasporaId.new.valid_value?(query)
  end

  # view this profile on the home pod, if you don't want to sign in...
  def authenticate_if_remote_profile!
    authenticate_user! if @person.try(:remote?)
  end

  def mark_corresponding_notifications_read
    Notification.where(recipient_id: current_user.id, target_type: "Person", target_id: @person.id, unread: true).each do |n|
      n.set_read_state( true )
    end
  end

  def person_stream
    @stream ||= Stream::Person.new(current_user, @person, max_time: max_time)
  end
end
