#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html,
             :js,
             :json

  def create
    @aspect = current_user.aspects.build(aspect_params)
    aspecting_person_id = params[:aspect][:person_id]

    if @aspect.save
      flash[:notice] = I18n.t('aspects.create.success', :name => @aspect.name)

      if current_user.getting_started || request.referer.include?("contacts")
        redirect_to :back
      elsif aspecting_person_id.present?
        connect_person_to_aspect(aspecting_person_id)
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

    @contacts_in_aspect = @aspect.contacts.includes(:aspect_memberships, :person => :profile).to_a.sort_by { |c| c.person.name }
    c = Contact.arel_table
    if @contacts_in_aspect.empty?
      @contacts_not_in_aspect = current_user.contacts.includes(:aspect_memberships, :person => :profile).to_a.sort_by { |c| c.person.name }
    else
      @contacts_not_in_aspect = current_user.contacts.where(c[:id].not_in(@contacts_in_aspect.map(&:id))).includes(:aspect_memberships, :person => :profile).to_a.sort_by { |c| c.person.name }
    end

    @contacts = @contacts_in_aspect + @contacts_not_in_aspect

    unless @aspect
      render :file => Rails.root.join('public', '404.html').to_s, :layout => false, :status => 404
    else
      @aspect_ids = [@aspect.id]
      @aspect_contacts_count = @aspect.contacts.size
      render :layout => false
    end
  end

  def update
    @aspect = current_user.aspects.where(:id => params[:id]).first

    if @aspect.update_attributes!(aspect_params)
      flash[:notice] = I18n.t 'aspects.update.success', :name => @aspect.name
    else
      flash[:error] = I18n.t 'aspects.update.failure', :name => @aspect.name
    end
    render :json => { :id => @aspect.id, :name => @aspect.name }
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

  private

  def connect_person_to_aspect(aspecting_person_id)
    @person = Person.find(aspecting_person_id)
    if @contact = current_user.contact_for(@person)
      @contact.aspects << @aspect
    else
      @contact = current_user.share_with(@person, @aspect)
    end
  end

  def aspect_params
    params.require(:aspect).permit(:name, :contacts_visible, :order_id)
  end
end
