#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    @posts = current_user.visible_posts(:by_members_of => :all).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
    @aspect = :all
    
    if current_user.getting_started == true
      redirect_to getting_started_path
    end
  end

  def create
    @aspect = current_user.aspects.create(params[:aspect])
    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success')
      respond_with @aspect
    else
      flash[:error] = I18n.t('aspects.create.failure')
      redirect_to :back
    end
  end

  def new
    @aspect = Aspect.new
  end

  def destroy
    @aspect = current_user.aspect_by_id params[:id]

    begin
      current_user.drop_aspect @aspect
      flash[:notice] = I18n.t 'aspects.destroy.success',:name => @aspect.name
    rescue RuntimeError => e 
      flash[:error] = e.message
    end

    respond_with :location => aspects_manage_path
  end

  def show
    @aspect = current_user.aspect_by_id params[:id]
    unless @aspect
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @contacts = @aspect.contacts
      @posts    = current_user.visible_posts( :by_members_of => @aspect ).paginate :per_page => 15, :order => 'created_at DESC'
      respond_with @aspect
    end
  end

  def manage
    @aspect = :manage
    @remote_requests = current_user.requests_for_me
  end

  def update
    @aspect = current_user.aspect_by_id(params[:id])

    @aspect.update_attributes( params[:aspect] )
    flash[:notice] = I18n.t 'aspects.update.success',:name => @aspect.name
    respond_with @aspect
  end

  def move_contact
    unless current_user.move_contact( :person_id => params[:person_id], :from => params[:from], :to => params[:to][:to])
      flash[:error] = I18n.t 'aspects.move_contact.error',:inspect => params.inspect
    end
    if aspect = current_user.aspect_by_id(params[:to][:to])
      flash[:notice] = I18n.t 'aspects.move_contact.success'
      render :nothing => true
    else
      flash[:notice] = I18n.t 'aspects.move_contact.failure'
      render aspects_manage_path
    end
  end

  def add_to_aspect
    if current_user.add_person_to_aspect( params[:person_id], params[:aspect_id])
      flash[:notice] =  I18n.t 'aspects.add_to_aspect.success'
    else 
      flash[:error] =  I18n.t 'aspects.add_to_aspect.failure'
    end

    if params[:manage]
      redirect_to aspects_manage_path
    else
      redirect_to aspect_path(params[:aspect_id])
    end
  end

  def remove_from_aspect
    if current_user.delete_person_from_aspect( params[:person_id], params[:aspect_id])
      flash[:notice] =  I18n.t 'aspects.remove_from_aspect.success'
    else 
      flash[:error] =  I18n.t 'aspects.remove_from_aspect.failure'
    end
    if params[:manage]
      redirect_to aspects_manage_path
    else
      redirect_to aspect_path(params[:aspect_id])
    end
  end
end
