#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = case params[:set]
    when "only_sharing"
      current_user.contacts.only_sharing
    when "all"
      current_user.contacts
    else
      if params[:a_id]
        @aspect = current_user.aspects.find(params[:a_id])
        @aspect.contacts
      else
        current_user.contacts.receiving
      end
    end

    respond_to do |format|
      format.html { @contacts = sort_and_paginate_profiles(@contacts) }
      format.json {
        @people = Person.joins(:contacts => :aspect_memberships).
          where(:contacts => { :user_id => current_user.id },
                :aspect_memberships => { :aspect_id => params[:aspect_ids] })

        render :json => @people.includes(:profile).to_json
      }
    end
  end

  def sharing
    @contacts = current_user.contacts.sharing.includes(:aspect_memberships)
    render :layout => false
  end

  def featured
    @featured = true
    @people = Person.featured_users
  end

  private

  def sort_and_paginate_profiles contacts
    contacts.
      includes(:aspects, :person => :profile).
      order('profiles.last_name ASC').
      paginate(:page => params[:page], :per_page => 25)
  end
end
