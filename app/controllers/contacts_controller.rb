#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
    @contacts = @contacts.for_a_stream(params[:page])

    respond_to do |format|
      format.json {
        @people = Person.all_from_aspects(params[:aspect_ids], current_user).for_json
        render :json => @people.to_json
      }
      format.any{}
    end
  end

  def sharing
    @contacts = current_user.contacts.sharing.includes(:aspect_memberships)
    render :layout => false
  end

  def spotlight
    @spotlight = true
    @people = Person.community_spotlight
  end

end
