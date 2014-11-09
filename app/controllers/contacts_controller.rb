#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_action :authenticate_user!

  layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }
  use_bootstrap_for :index, :spotlight

  def index
    respond_to do |format|

      # Used for normal requests to contacts#index
      format.html { set_up_contacts }

      # Used by the mobile site
      format.mobile { set_up_contacts_mobile }

      # Used to populate mentions in the publisher
      format.json {
        aspect_ids = params[:aspect_ids] || current_user.aspects.map(&:id)
        @people = Person.all_from_aspects(aspect_ids, current_user).for_json
        render :json => @people.to_json
      }
    end
  end

  def spotlight
    @spotlight = true
    @people = Person.community_spotlight
  end

  private

  def set_up_contacts
    type = params[:set].presence
    type ||= "by_aspect" if params[:a_id].present?
    type ||= "receiving"

    @contacts = contacts_by_type(type)
    @contacts_size = @contacts.length
  end

  def contacts_by_type(type)
    contacts = case type
      when "all"
        [current_user.contacts]
      when "only_sharing"
        [current_user.contacts.only_sharing]
      when "receiving"
        [current_user.contacts.receiving]
      when "by_aspect"
        @aspect = current_user.aspects.find(params[:a_id])
        @contacts_in_aspect = @aspect.contacts
        @contacts_not_in_aspect = current_user.contacts.where.not(contacts: {id: @contacts_in_aspect.pluck(:id) })
        [@contacts_in_aspect, @contacts_not_in_aspect].map {|relation|
          relation.includes(:aspect_memberships)
        }
      else
        raise ArgumentError, "unknown type #{type}"
      end

    contacts.map {|relation|
      relation.includes(:person => :profile).to_a.tap {|contacts|
        contacts.sort_by! {|contact| contact.person.name }
      }
    }.inject(:+).paginate(:page => params[:page], :per_page => 25)
  end

  def set_up_contacts_mobile
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
