#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => [:show, :create]
  respond_to :js

  def index
    if params[:a_ids]
      @aspects = current_user.aspects.where(:id => params[:a_ids]).includes(:contacts => {:person => :profile})
      @selected_contacts = @aspects.inject([]){|arr, aspect| arr.concat(aspect.contacts)}
      @selected_contacts.uniq!
    else
      @aspects = current_user.aspects.includes(:contacts => {:person => :profile})
      @selected_contacts = current_user.contacts
    end

    # redirect to signup
    if (current_user.getting_started == true || @aspects.blank?) && !request.format.mobile?
      redirect_to getting_started_path
    else
      if params[:sort_order].blank? and session[:sort_order].blank?
         session[:sort_order] = 'updated_at'
      elsif not params[:sort_order].blank? and not session[:sort_order] == params[:sort_order]
        session[:sort_order] = params[:sort_order] == 'created_at' ? 'created_at' : 'updated_at'
      end
      sort_order = session[:sort_order] == 'created_at' ? 'created_at' : 'updated_at'
      @aspect_ids = @aspects.map{|a| a.id}

      @posts = StatusMessage.joins(:aspects).where(:pending => false,
               :aspects => {:id => @aspect_ids}).includes(:comments, :photos).select('DISTINCT `posts`.*').paginate(
               :page => params[:page], :per_page => 15, :order => sort_order + ' DESC')
      @fakes = PostsFake.new(@posts)

      @contacts = current_user.contacts.includes(:person => :profile)

      @aspect = :all unless params[:a_ids]
      @aspect ||= @aspects.first #used in mobile

    end
  end
  def create
    @aspect = current_user.aspects.create(params[:aspect])
    #hack, we don't know why mass assignment is not working
    @aspect.contacts_visible = params[:aspect][:contacts_visible]
    @aspect.save

    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success', :name => @aspect.name)
      if current_user.getting_started
        redirect_to :back
      elsif request.env['HTTP_REFERER'].include?("aspects/manage")
        redirect_to :back
      elsif params[:aspect][:share_with]
        @contact = Contact.where(:id => params[:aspect][:contact_id]).first
        @person = Person.where(:id => params[:aspect][:person_id]).first
        @contact = current_user.contact_for(@person) || Contact.new

        respond_to do |format|
          format.js { render :json => {:html => render_to_string(
              :partial => 'aspects/aspect_list_item',
              :locals => {:aspect => @aspect,
                            :person => @person,
                            :contact => @contact}
                                      ), :aspect_id => @aspect.id},:status => 201 }
              end
      else
        respond_with @aspect
      end
    else
      flash[:error] = I18n.t('aspects.create.failure')
      redirect_to :back
    end
  end

  def new
    @aspect = Aspect.new
  end

  def destroy
    @aspect = current_user.aspects.where(:id => params[:id]).first

    begin
      current_user.drop_aspect @aspect
      flash[:notice] = I18n.t 'aspects.destroy.success',:name => @aspect.name
      redirect_to :back
    rescue RuntimeError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  def show
    @aspect = current_user.aspects.where(:id => params[:id]).first
    if @aspect
      redirect_to aspects_path('a_ids[]' => @aspect.id)
    else
      redirect_to aspects_path
    end
  end

  def edit
    @aspect = current_user.aspects.where(:id => params[:id]).includes(:contacts => {:person => :profile}).first
    @contacts = current_user.contacts.includes(:person => :profile)
    unless @aspect
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @aspect_ids = [@aspect.id]
      @aspect_contacts_count = @aspect.contacts.length
      render :layout => false
    end
  end

  def manage
    @aspect = :manage
    @contacts = current_user.contacts.includes(:person => :profile)
    @remote_requests = Request.where(:recipient_id => current_user.person.id).includes(:sender => :profile)
    @aspects = @all_aspects.includes(:contacts => {:person => :profile})
  end

  def update
    @aspect = current_user.aspects.where(:id => params[:id]).first

    if @aspect.update_attributes!( params[:aspect] )
      #hack, we don't know why mass assignment is not working
      @aspect.contacts_visible = params[:aspect][:contacts_visible]
      @aspect.save
      flash[:notice] = I18n.t 'aspects.update.success',:name => @aspect.name
    else
      flash[:error] = I18n.t 'aspects.update.failure',:name => @aspect.name
    end

    respond_with @aspect
  end

  def move_contact
    @person = Person.find(params[:person_id])
    @from_aspect = current_user.aspects.where(:id => params[:from]).first
    @to_aspect = current_user.aspects.where(:id => params[:to][:to]).first

    response_hash = { }

    unless current_user.move_contact( @person, @to_aspect, @from_aspect)
      flash[:error] = I18n.t 'aspects.move_contact.error',:inspect => params.inspect
    end
    if aspect = current_user.aspects.where(:id => params[:to][:to]).first
      response_hash[:notice] = I18n.t 'aspects.move_contact.success'
      response_hash[:success] = true
    else
      response_hash[:notice] = I18n.t 'aspects.move_contact.failure'
      response_hash[:success] = false
    end

    render :text => response_hash.to_json
  end
end
