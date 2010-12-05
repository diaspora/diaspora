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
    @requests = Request.all(:to_id.in => @people.map{|p| p.id}, :from_id => current_user.person.id)
    
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
      @post_hashes = hashes_for_posts @posts
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

    # upload and set new profile photo
    params[:person][:profile] ||= {}
    if params[:person][:profile][:image].present?
      raw_image = params[:person][:profile].delete(:image)
      params[:profile_image_hash] = { :user_file => raw_image, :to => "all" }

      photo = current_user.build_post(:photo, params[:profile_image_hash])
      if photo.save!

        params[:person][:profile][:image_url] = photo.url(:thumb_large)
        params[:person][:profile][:image_url_medium] = photo.url(:thumb_medium)
        params[:person][:profile][:image_url_small] = photo.url(:thumb_small)
      end
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
