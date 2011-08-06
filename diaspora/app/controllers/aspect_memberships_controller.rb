#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class AspectMembershipsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json, :js

  def destroy
    #note :id is garbage

    @person_id = params[:person_id]
    @aspect_id = params[:aspect_id]

    @contact = current_user.contact_for(Person.where(:id => @person_id).first)
    membership = @contact ? @contact.aspect_memberships.where(:aspect_id => @aspect_id).first : nil

    if membership && membership.destroy 
        @aspect = membership.aspect
        flash.now[:notice] = I18n.t 'aspect_memberships.destroy.success'

        respond_with do |format|
          format.all{ }
          format.json{ render :json => {
            :person_id => @person_id,
            :aspect_ids => @contact.aspects.map{|a| a.id}
          } }
        end

      else
        flash.now[:error] = I18n.t 'aspect_memberships.destroy.failure'
        errors = membership ? membership.errors.full_messages : t('aspect_memberships.destroy.no_membership')
        respond_to do |format|
          format.js  { render :text => errors, :status => 403 }
          format.html{
            redirect_to :back
          }
      end
    end
  end

  def create
    @person = Person.find(params[:person_id])
    @aspect = current_user.aspects.where(:id => params[:aspect_id]).first

    if @contact = current_user.share_with(@person, @aspect)
      flash.now[:notice] =  I18n.t 'aspects.add_to_aspect.success'
      respond_with AspectMembership.where(:contact_id => @contact.id, :aspect_id => @aspect.id).first
    else
      flash[:error] = I18n.t 'contacts.create.failure'
      #TODO(dan) take this out once the .js template is removed
      render :nothing => true
    end
  end

  def update
    @person = Person.find(params[:person_id])
    @from_aspect = current_user.aspects.where(:id => params[:aspect_id]).first
    @to_aspect = current_user.aspects.where(:id => params[:to]).first

    response_hash = { }

    unless current_user.move_contact( @person, @to_aspect, @from_aspect)
      flash[:error] = I18n.t 'aspects.move_contact.error',:inspect => params.inspect
    end
    if aspect = current_user.aspects.where(:id => params[:to]).first
      response_hash[:notice] = I18n.t 'aspects.move_contact.success'
      response_hash[:success] = true
    else
      response_hash[:notice] = I18n.t 'aspects.move_contact.failure'
      response_hash[:success] = false
    end

    render :text => response_hash.to_json
  end

end
