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


class AspectsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    @posts = current_user.visible_posts(:by_members_of => :all).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
    @aspect = :all
  end

  def create
    @aspect = current_user.aspect params[:aspect]
    flash[:notice] = "Click on the plus on the left side to tell Diaspora who can see your new aspect."
    respond_with @aspect
  end
  
  def new
    @aspect = Aspect.new
  end
  
  def destroy
    @aspect = Aspect.find_by_id params[:id]
    @aspect.destroy
    flash[:notice] = "You are no longer sharing the aspect called #{@aspect.name}."
    respond_with :location => aspects_url
  end
  
  def show
    @aspect   = Aspect.find_by_id params[:id]
    @friends = @aspect.people
    @posts   = current_user.visible_posts( :by_members_of => @aspect ).paginate :per_page => 15, :order => 'created_at DESC'

    respond_with @aspect
  end

  def edit
    @aspects = current_user.aspects
    @remote_requests = Request.for_user current_user
  end

  def update
    @aspect = Aspect.find_by_id(params[:id])
    @aspect.update_attributes(params[:aspect])
    flash[:notice] = "Your aspect, #{@aspect.name}, has been successfully edited."
    respond_with @aspect
  end

  def move_friends
    params[:moves].each{ |move|
      move = move[1]
      unless current_user.move_friend(move)
        flash[:error] = "Aspect editing failed for friend #{Person.find_by_id( move[:friend_id] ).real_name}."
        redirect_to Aspect.first, :action => "edit"
        return
      end
    }

    flash[:notice] = "Aspects edited successfully."
    redirect_to Aspect.first, :action => "edit"
  end

  def move_friend
    unless current_user.move_friend( :friend_id => params[:friend_id], :from => params[:from], :to => params[:to][:to]) 
      flash[:error] = "didn't work #{params.inspect}"
    end
    if aspect = Aspect.first(:id => params[:to][:to])
      flash[:notice] = "You are now showing your friend a different aspect of yourself."
      respond_with aspect
    else
      flash[:notice] = "You are now showing your friend a different aspect of yourself."
      respond_with Person.first(:id => params[:friend_id])
    end
  end
end
