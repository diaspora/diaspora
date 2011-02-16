#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class AspectMembershipsController < ApplicationController 
  before_filter :authenticate_user!

  def new
    render :nothing => true
  end

 
  def destroy 
    #note :id is garbage


      @person_id = params[:person_id]
      @aspect_id = params[:aspect_id]

      contact = current_user.contact_for(Person.where(:id => @person_id).first)

      membership = contact ? contact.aspect_memberships.where(:aspect_id => @aspect_id).first : nil

      if membership && membership.destroy
        flash.now[:notice] = I18n.t 'aspect_memberships.destroy.success'

        respond_to do |format|
          format.js { render :json => {:button_html =>
            render_to_string(:partial => 'aspects/remove_from_aspect',
                             :locals => {:aspect_id => @aspect_id,
                               :person_id => @person_id}),
                               :aspect_id => @aspect_id
          }}
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
    @aspect = current_user.aspects.find(params[:aspect_id])
    @contact = current_user.contact_for(@person)


    current_user.add_contact_to_aspect(contact, aspect)

    flash.now[:notice] =  I18n.t 'aspects.add_to_aspect.success'

    respond_to do |format|
      format.js { render :json => {
        :button_html => render_to_string(:partial => 'aspects/add_to_aspect',
                         :locals => {:aspect_id => @aspect.id,
                                     :person_id => @person.id}),
        :badge_html =>  render_to_string(:partial => 'aspects/aspect_badge',
                            :locals => {:aspect => @aspect})
        }}
      format.html{ redirect_to aspect_path(@aspect.id)}
    end
  end

end
