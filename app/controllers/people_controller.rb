#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


class PeopleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:index, :show]
  
  def index
    @aspects_dropdown_array = current_user.aspects.collect{|x| [x.to_s, x.id]} 
    @people = Person.search params[:q]
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
