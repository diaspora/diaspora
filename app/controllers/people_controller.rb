#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspect = :search

    @people = Person.search(params[:q]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
    if @people.count == 1
      redirect_to @people.first
    else
      @hashes = hashes_for_people(@people, @aspects)
      #only do it if it is an email address
      if params[:q].try(:match, Devise.email_regexp)
        webfinger(params[:q])
      end
    end
  end

  def hashes_for_people people, aspects
    ids = people.map{|p| p.id}
    requests = {}
    Request.all(:from_id.in => ids, :to_id => current_user.person.id).each do |r|
      requests[r.to_id] = r
    end
    contacts = {}
    Contact.all(:user_id => current_user.id, :person_id.in => ids).each do |contact|
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
    @person = Person.find(params[:id].to_id)
    @post_type = :all

    if @person
      @incoming_request = Request.to(current_user).from(@person).first

      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @aspects_with_person = []

      if @contact
        @aspects_with_person = @contact.aspects
        @similar_people = similar_people @contact
      end

      if (@person != current_user.person) && (!@contact || @contact.pending)
        @commenting_disabled = true
      else
        @commenting_disabled = false
      end

      @posts = current_user.posts_from(@person).paginate :page => params[:page]
      @post_hashes = hashes_for_posts @posts

      respond_with @person, :locals => {:post_type => :all}

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def destroy
    current_user.disconnect(current_user.visible_person_by_id(params[:id]))
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
    params[:profile][:photo] = Photo.first(:person_id => current_user.person.id, :id => params[:photo_id]) if params[:photo_id]

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
    @person = Person.find(params[:id].to_id)
    @contact = current_user.contact_for(@person)
    @aspects_with_person = []

    if @contact
      @aspects_with_person = @contact.aspects
    end

    @aspects_without_person = @aspects.reject do |aspect|
      @aspects_with_person.include?(aspect)
    end

    render :layout => nil
  end

  private
  def hashes_for_posts posts
    post_ids = posts.map{|p| p.id}
    comment_hash = Comment.hash_from_post_ids post_ids
    person_hash = Person.from_post_comment_hash comment_hash
    photo_hash = Photo.hash_from_post_ids post_ids

    posts.map do |post|
      {:post => post,
        :person => @person,
        :photos => photo_hash[post.id],
        :comments => comment_hash[post.id].map do |comment|
          {:comment => comment,
            :person => person_hash[comment.person_id],
          }
        end,
      }
    end
  end

  def webfinger(account, opts = {})
    Resque.enqueue(Jobs::SocketWebfinger, current_user.id, account, opts)
  end

end
