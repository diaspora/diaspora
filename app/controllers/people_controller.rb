#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspect = :search
    params[:q] ||= params[:term]
    
    if (params[:q][0] == 35 || params[:q][0] == '#') && params[:q].length > 1
      redirect_to "/tags/#{params[:q].gsub("#", "")}"
      return
    end

    limit = params[:limit] || 15

    @people = Person.search(params[:q], current_user).paginate :page => params[:page], :per_page => limit
    @hashes = hashes_for_people(@people, @aspects) unless request.format == :json

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
    @post_type = :all
    @aspect = :profile
    @share_with = (params[:share_with] == 'true')

    if @person

      @profile = @person.profile

      if current_user
        @incoming_request = current_user.request_from(@person)
        @contact = current_user.contact_for(@person)
        @aspects_with_person = []
        if @contact
          @aspects_with_person = @contact.aspects
          @aspect_ids = @aspects_with_person.map(&:id)
          @contacts_of_contact = @contact.contacts

        else
          @contact ||= Contact.new
          @contacts_of_contact = []
        end

        if (@person != current_user.person) && (!@contact || @contact.pending)
          @commenting_disabled = true
        else
          @commenting_disabled = false
        end
        @posts = current_user.posts_from(@person).where(:type => "StatusMessage").paginate(:per_page => 15, :page => params[:page])
      else
        @commenting_disabled = true
        @posts = @person.posts.where(:type => "StatusMessage", :public => true).paginate(:per_page => 15, :page => params[:page], :order => 'created_at DESC')
      end

      @fakes = PostsFake.new(@posts)
      respond_with @person, :locals => {:post_type => :all}

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

  private
  def webfinger(account, opts = {})
    Resque.enqueue(Job::SocketWebfinger, current_user.id, account, opts)
  end
end
