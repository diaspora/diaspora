#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def sharing
    @contacts = current_user.contacts.sharing.includes(:aspect_memberships)
    render :layout => false
  end
end
