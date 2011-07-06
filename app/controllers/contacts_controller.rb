#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @aspect = :manage

    if params[:a_id]
      @aspect_ = current_user.aspects.find(params["a_id"])
      @contacts = @aspect_.contacts.includes(:aspects, :person => :profile).order('profiles.last_name ASC').paginate(:page => params[:page], :per_page => 25)
    elsif params[:set] == "only_sharing"
      @contacts = current_user.contacts.only_sharing.includes(:aspects, :person => :profile).order('profiles.last_name ASC').paginate(:page => params[:page], :per_page => 25)
    elsif params[:set] != "all"
      @contacts = current_user.contacts.receiving.includes(:aspects, :person => :profile).order('profiles.last_name ASC').paginate(:page => params[:page], :per_page => 25)
    else
      @contacts = current_user.contacts.includes(:aspects, :person => :profile).order('profiles.last_name ASC').paginate(:page => params[:page], :per_page => 25)
    end
  end

  def sharing
    @contacts = current_user.contacts.sharing.includes(:aspect_memberships)
    render :layout => false
  end

end
