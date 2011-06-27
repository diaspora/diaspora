#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class AspectMembershipsController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    #note :id is garbage

    @person_id = params[:person_id]
    @aspect_id = params[:aspect_id]

    @contact = current_user.contact_for(Person.where(:id => @person_id).first)
    membership = @contact ? @contact.aspect_memberships.where(:aspect_id => @aspect_id).first : nil

    if membership && membership.destroy 
        @aspect = membership.aspect

        flash.now[:notice] = I18n.t 'aspect_memberships.destroy.success'

        respond_to do |format|
          format.all {}
          format.html{
            redirect_to :back
          }
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

    else
      flash[:error] = I18n.t 'contacts.create.failure'
      redirect_to :back
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
