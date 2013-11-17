#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|

      # Used for normal requests to contacts#index and subsequent infinite scroll calls
      format.html { set_up_contacts }

      # Used by the mobile site
      format.mobile { set_up_contacts }

      # Used to populate mentions in the publisher
      format.json {
        aspect_ids = params[:aspect_ids] || current_user.aspects.map(&:id)
        @people = Person.all_from_aspects(aspect_ids, current_user).for_json
        render :json => @people.to_json
      }
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

  private

  def set_up_contacts
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
    @contacts = @contacts.for_a_stream.paginate(:page => params[:page], :per_page => 25)
    @contacts_size = @contacts.length
  end
end
