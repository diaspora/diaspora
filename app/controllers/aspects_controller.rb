#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, "lib", 'stream', "aspect")

class AspectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_selected_aspects, :only => :index
  before_filter :ensure_page, :only => :index

  respond_to :html,
             :js,
             :json

  def index
    @backbone = true
    stream_klass = Stream::Aspect
    aspect_ids = (session[:a_ids] ? session[:a_ids] : [])
    @stream = Stream::Aspect.new(current_user, aspect_ids,
                                 :max_time => params[:max_time].to_i)

    respond_with do |format|
      format.html do
        if params[:only_posts]
          render :partial => 'shared/stream', :locals => {:posts => @stream.stream_posts}
        else
          render 'aspects/index'
        end
      end
      format.json{ render_for_api :backbone, :json => @stream.stream_posts, :root => :posts }
    end
  end

  def create
    @aspect = current_user.aspects.create(params[:aspect])

    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success', :name => @aspect.name)
      if current_user.getting_started
        redirect_to :back
      elsif request.env['HTTP_REFERER'].include?("contacts")
        redirect_to :back
      elsif params[:aspect][:person_id].present?
        @person = Person.where(:id => params[:aspect][:person_id]).first

        if @contact = current_user.contact_for(@person)
          @contact.aspects << @aspect
        else
          @contact = current_user.share_with(@person, @aspect)
        end
      else
        redirect_to contacts_path(:a_id => @aspect.id)
      end
    else
      respond_to do |format|
        format.js { render :text => I18n.t('aspects.create.failure'), :status => 422 }
        format.html do
          flash[:error] = I18n.t('aspects.create.failure')
          redirect_to :back
        end
      end
    end
  end

  def new
    @aspect = Aspect.new
    @person_id = params[:person_id]
    @remote = params[:remote] == "true"
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def destroy
    @aspect = current_user.aspects.where(:id => params[:id]).first

    begin
      @aspect.destroy
      flash[:notice] = I18n.t 'aspects.destroy.success', :name => @aspect.name
    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = I18n.t 'aspects.destroy.failure', :name => @aspect.name
    end
    if request.referer.include?('contacts')
      redirect_to contacts_path
    else
      redirect_to aspects_path
    end
  end

  def show
    if @aspect = current_user.aspects.where(:id => params[:id]).first
      redirect_to aspects_path('a_ids[]' => @aspect.id)
    else
      redirect_to aspects_path
    end
  end

  def edit
    @aspect = current_user.aspects.where(:id => params[:id]).includes(:contacts => {:person => :profile}).first

    @contacts_in_aspect = @aspect.contacts.includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    c = Contact.arel_table
    if @contacts_in_aspect.empty?
      @contacts_not_in_aspect = current_user.contacts.includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    else
      @contacts_not_in_aspect = current_user.contacts.where(c[:id].not_in(@contacts_in_aspect.map(&:id))).includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    end

    @contacts = @contacts_in_aspect + @contacts_not_in_aspect

    unless @aspect
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @aspect_ids = [@aspect.id]
      @aspect_contacts_count = @aspect.contacts.size
      render :layout => false
    end
  end

  def update
    @aspect = current_user.aspects.where(:id => params[:id]).first

    if @aspect.update_attributes!(params[:aspect])
      flash[:notice] = I18n.t 'aspects.update.success', :name => @aspect.name
    else
      flash[:error] = I18n.t 'aspects.update.failure', :name => @aspect.name
    end
    render :json => { :name => @aspect.name }
  end

  def toggle_contact_visibility
    @aspect = current_user.aspects.where(:id => params[:aspect_id]).first

    if @aspect.contacts_visible?
      @aspect.contacts_visible = false
    else
      @aspect.contacts_visible = true
    end
    @aspect.save
  end

  def ensure_page
    params[:max_time] ||= Time.now + 1
  end

  private

  def save_selected_aspects
    if params[:a_ids].present?
      session[:a_ids] = params[:a_ids]
    end
  end
end
