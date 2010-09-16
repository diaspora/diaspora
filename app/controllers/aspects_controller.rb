#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


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
    respond_with :location => aspects_manage_path
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

  def manage
    @aspect = :manage
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
