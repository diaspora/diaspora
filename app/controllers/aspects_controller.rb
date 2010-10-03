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
    @aspect = current_user.aspect(params[:aspect])
    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success')
    else
      flash[:error] = I18n.t('aspects.create.failure')
    end
    respond_with :location => aspects_manage_path
  end

  def new
    @aspect = Aspect.new
  end

  def destroy
    @aspect = current_user.aspect_by_id params[:id]

    begin
      current_user.drop_aspect @aspect
      flash[:notice] = i18n.t 'aspects.destroy.success',:name => @aspect.name
    rescue RuntimeError => e
      flash[:error] = e.message
    end

    respond_with :location => aspects_manage_path
  end

  def show
    @aspect  = current_user.aspect_by_id params[:id]
    @friends = @aspect.people
    @posts   = current_user.visible_posts( :by_members_of => @aspect ).paginate :per_page => 15, :order => 'created_at DESC'

    respond_with @aspect
  end

  def public
    @fb_access_url = MiniFB.oauth_url(FB_APP_ID, APP_CONFIG[:pod_url] + "services/create",
                                      :scope=>MiniFB.scopes.join(","))

    @posts = current_user.visible_posts(:public => true).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'

    respond_with @aspect
  end

  def manage
    @aspect = :manage
    @remote_requests = Request.for_user(current_user).all
  end

  def update
    @aspect = current_user.aspect_by_id(params[:id])

    data = clean_hash(params[:aspect])
    @aspect.update_attributes( data )
    flash[:notice] = i18n.t 'aspects.update.success',:name => @aspect.name
    respond_with @aspect
  end

  def move_friends
    params[:moves].each{ |move|
      move = move[1]
      unless current_user.move_friend(move)
        flash[:error] = i18n.t 'aspects.move_friends.failure', :real_name => Person.find_by_id( move[:friend_id] ).real_name
        redirect_to aspects_manage_path
        return
      end
    }

    flash[:notice] = i18n.t 'aspects.move_friends.success'
    redirect_to aspects_manage_path
  end

  def move_friend
    unless current_user.move_friend( :friend_id => params[:friend_id], :from => params[:from], :to => params[:to][:to])
      flash[:error] = I18n.t 'aspects.move_friend.error',:inspect => params.inspect
    end
    if aspect = current_user.aspect_by_id(params[:to][:to])
      flash[:notice] = I18n.t 'aspects.move_friend.success'
      render :nothing => true
    else
      flash[:notice] = I18n.t 'aspects.move_friend.failure'
      render aspects_manage_path
    end
  end

  private
  def clean_hash(params)
    return {
      :name => params[:name]
    }
  end

end
