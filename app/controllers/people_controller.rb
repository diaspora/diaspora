#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  respond_to :html, :except => [:tag_index]
  respond_to :json, :only => [:index, :show]
  respond_to :js, :only => [:tag_index]

  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end

  def index
    @aspect = :search
    params[:q] ||= params[:term] || ''

    if (params[:q][0] == 35 || params[:q][0] == '#') && params[:q].length > 1
      redirect_to tag_path(:name => params[:q].gsub(/[#\.]/, ''), :q => params[:q])
      return
    end

    limit = params[:limit] ? params[:limit].to_i : 15

    respond_to do |format|
      format.json do
        @people = Person.search(params[:q], current_user).limit(limit)
        render :json => @people
      end

      format.html do
        #only do it if it is an email address
        if diaspora_id?(params[:q])
          people = Person.where(:diaspora_handle => params[:q].downcase)
          webfinger(params[:q]) if people.empty?
        else
          people = Person.search(params[:q], current_user)
        end
        @people = people.paginate( :page => params[:page], :per_page => 15)
        @hashes = hashes_for_people(@people, @aspects)
      end
      format.mobile do
        #only do it if it is an email address
        if diaspora_id?(params[:q])
          people = Person.where(:diaspora_handle => params[:q])
          webfinger(params[:q]) if people.empty?
        else
          people = Person.search(params[:q], current_user)
        end
        @people = people.paginate( :page => params[:page], :per_page => 15)
        @hashes = hashes_for_people(@people, @aspects)
      end
    end
  end

  def tag_index
    profiles = Profile.tagged_with(params[:name]).where(:searchable => true).select('profiles.id, profiles.person_id')
    @people = Person.where(:id => profiles.map{|p| p.person_id}).paginate(:page => params[:page], :per_page => 15)
    respond_with @people
  end

  def hashes_for_people people, aspects
    ids = people.map{|p| p.id}
    contacts = {}
    Contact.unscoped.where(:user_id => current_user.id, :person_id => ids).each do |contact|
      contacts[contact.person_id] = contact
    end

    people.map{|p|
      {:person => p,
        :contact => contacts[p.id],
        :aspects => aspects}
    }
  end

  def show
    @person = Person.find_from_id_or_username(params)

    if remote_profile_with_no_user_session?
      raise ActiveRecord::RecordNotFound
    end

    @post_type = :all
    @aspect = :profile
    @share_with = (params[:share_with] == 'true')

    max_time = params[:max_time] ? Time.at(params[:max_time].to_i) : Time.now
    @profile = @person.profile

    unless params[:format] == "json" # hovercard
      if current_user
        @contact = current_user.contact_for(@person)
        @aspects_with_person = []
        if @contact && !params[:only_posts]
          @aspects_with_person = @contact.aspects
          @aspect_ids = @aspects_with_person.map(&:id)
          @contacts_of_contact_count = @contact.contacts.count
          @contacts_of_contact = @contact.contacts.limit(8)

        else
          @contact ||= Contact.new
          @contacts_of_contact_count = 0
          @contacts_of_contact = []
        end

        if (@person != current_user.person) && !@contact.persisted?
          @commenting_disabled = true
        else
          @commenting_disabled = false
        end
        @posts = current_user.posts_from(@person).where(:type => ["StatusMessage", "Reshare", "ActivityStreams::Photo"]).includes(:comments).limit(15).where(StatusMessage.arel_table[:created_at].lt(max_time))
      else
        @commenting_disabled = true
        @posts = @person.posts.where(:type => ["StatusMessage", "Reshare", "ActivityStreams::Photo"], :public => true).includes(:comments).limit(15).where(StatusMessage.arel_table[:created_at].lt(max_time)).order('posts.created_at DESC')
      end
      @posts.includes(:author => :profile)
    end

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @posts}
    else
      respond_to do |format|
        format.all { respond_with @person, :locals => {:post_type => :all} }
        format.json {
          render :json => @person.to_json(:includes => params[:includes])
        }
      end
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

  def contacts
    @person = Person.find_by_id(params[:person_id])
    if @person
      @contact = current_user.contact_for(@person)
      @aspect = :profile
      @contacts_of_contact = @contact.contacts.paginate(:page => params[:page], :per_page => (params[:limit] || 15))
      @hashes = hashes_for_people @contacts_of_contact, @aspects
      @aspects_with_person = @contact.aspects
      @aspect_ids = @aspects_with_person.map(&:id)
    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def aspect_membership_dropdown
    @person = Person.find(params[:person_id])
    if @person == current_user.person
      render :text => I18n.t('people.person.thats_you')
    else
      @contact = current_user.contact_for(@person) || Contact.new
      render :partial => 'aspect_membership_dropdown', :locals => {:contact => @contact, :person => @person, :hang => 'left'}
    end
  end

  def diaspora_id?(query)
    !query.try(:match, /^(\w)*@([a-zA-Z0-9]|[-]|[.]|[:])*$/).nil?
  end

  private
  def webfinger(account, opts = {})
    Resque.enqueue(Jobs::SocketWebfinger, current_user.id, account, opts)
  end

  def remote_profile_with_no_user_session?
    @person && @person.remote? && !user_signed_in?
  end


end
