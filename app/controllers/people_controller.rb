#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  helper :comments
  before_filter :authenticate_user!, :except => [:show]
  before_filter :ensure_page, :only => :show

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspect = :search
    params[:q] ||= params[:term] || ''

    if (params[:q][0] == 35 || params[:q][0] == '#') && params[:q].length > 1
      redirect_to "/tags/#{params[:q].gsub("#", "")}"
      return
    end

    limit = params[:limit] ? params[:limit].to_i : 15

    respond_to do |format|
      format.json do
        @people = Person.search(params[:q], current_user).limit(limit)
        render :json => @people
      end

      format.all do
        @people = Person.search(params[:q], current_user).paginate :page => params[:page], :per_page => limit
        @hashes = hashes_for_people(@people, @aspects)

        #only do it if it is an email address
        if params[:q].try(:match, Devise.email_regexp)
          webfinger(params[:q])
        end
      end
    end
  end

  def hashes_for_people people, aspects
    ids = people.map{|p| p.id}
    requests = {}
    Request.where(:sender_id => ids, :recipient_id => current_user.person.id).each do |r|
      requests[r.id] = r
    end
    contacts = {}
    Contact.unscoped.where(:user_id => current_user.id, :person_id => ids).each do |contact|
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
    if @person && @person.remote? && !user_signed_in?
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
      return
    end


    @post_type = :all
    @aspect = :profile
    @share_with = (params[:share_with] == 'true')

    if @person

      @profile = @person.profile

      if current_user
        @incoming_request = current_user.request_from(@person)
        @contact = current_user.contact_for(@person)
        @aspects_with_person = []
        if @contact && !params[:only_posts]
          @aspects_with_person = @contact.aspects
          @aspect_ids = @aspects_with_person.map(&:id)
          @contacts_of_contact_count = @contact.contacts.count
          @contacts_of_contact = @contact.contacts.limit(36)

        else
          @contact ||= Contact.new
          @contacts_of_contact_count = 0
          @contacts_of_contact = []
        end

        if (@person != current_user.person) && (!@contact || !@contact.persisted? || @contact.pending)
          @commenting_disabled = true
        else
          @commenting_disabled = false
        end
        @posts = current_user.posts_from(@person).where(:type => "StatusMessage").includes(:comments).limit(15).offset(15*(params[:page]-1))
      else
        @commenting_disabled = true
        @posts = @person.posts.where(:type => "StatusMessage", :public => true).includes(:comments).limit(15).offset(15*(params[:page]-1)).order('posts.created_at DESC')
      end

      @posts = PostsFake.new(@posts)

      if params[:only_posts]
        render :partial => 'shared/stream', :locals => {:posts => @posts}
      else
        respond_with @person, :locals => {:post_type => :all}
      end

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
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
    @person = Person.find(params[:id])
    if @person
      @contact = current_user.contact_for(@person)
      @aspect = :profile
      @contacts_of_contact = @contact.contacts.paginate(:page => params[:page], :per_page => (params[:limit] || 15))
      @hashes = hashes_for_people @contacts_of_contact, @aspects
      @incoming_request = current_user.request_from(@person)
      @contact = current_user.contact_for(@person)
      @aspects_with_person = @contact.aspects
      @aspect_ids = @aspects_with_person.map(&:id)
    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end
  private
  def webfinger(account, opts = {})
    Resque.enqueue(Job::SocketWebfinger, current_user.id, account, opts)
  end
end
