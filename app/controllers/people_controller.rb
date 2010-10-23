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
      @latest_status_message = current_user.raw_visible_posts.find_all_by__type_and_person_id("StatusMessage", params[:id]).last
      @post_count = @posts.count
      respond_with @person
    end
  end

  def destroy
    current_user.unfriend(current_user.visible_person_by_id(params[:id]))
    respond_with :location => root_url
  end

end
