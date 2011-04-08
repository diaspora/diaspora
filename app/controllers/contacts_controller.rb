#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @person = Person.find(params[:person_id])
    @aspects_with_person = []
    @aspects_without_person = current_user.aspects
    @contact = Contact.new
    render :layout => false
  end

  def edit
    @contact = current_user.contacts.unscoped.find(params[:id])
    @person = @contact.person

    @all_aspects ||= current_user.aspects
    @aspects_with_person = @contact.aspects || []

    @aspects_without_person = @all_aspects - @aspects_with_person

    render :layout => false
  end

  def destroy
    contact = current_user.contacts.find(params[:id])

    if current_user.disconnect(contact)
      flash[:notice] = I18n.t('contacts.destroy.success', :name => contact.person.name)
    else
      flash[:error] = I18n.t('contacts.destroy.failure', :name => contact.person.name)
    end
    redirect_to contact.person
  end

end
