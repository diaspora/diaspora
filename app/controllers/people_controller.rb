#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class PeopleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]

  def index
    @aspects_dropdown_array = current_user.aspects.collect{|x| [x.to_s, x.id]}
    @aspect = :all
    @people = Person.search(params[:q]).paginate :page => params[:page], :per_page => 25, :order => 'created_at DESC'

    respond_with @people
  end

  def show
    @person = current_user.visible_person_by_id(params[:id])
    @profile = @person.profile
    @aspects_with_person = current_user.aspects_with_person(@person)
    @aspects_dropdown_array = current_user.aspects.collect{|x| [x.to_s, x.id]}
    @posts = current_user.visible_posts_from_others(:from => @person).paginate :page => params[:page], :order => 'created_at DESC'
    @latest_status_message = current_user.raw_visible_posts.find_all_by__type_and_person_id("StatusMessage", params[:id]).last
    @post_count = @posts.count
    respond_with @person
  end

  def destroy
    current_user.unfriend(current_user.visible_person_by_id(params[:id]))
    respond_with :location => root_url
  end

end
