#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    note = Notification.find_by_user_id_and_id(current_user.id, params[:id])
    if note
      note.delete
      render :nothing => true
    else
      render :nothing => true, :code => 404
    end
  end

  def index
  
  end
end
