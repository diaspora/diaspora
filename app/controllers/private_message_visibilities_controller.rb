#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class PrivateMessageVisibilitiesController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    @vis = PrivateMessageVisibility.where(:person_id => current_user.person.id,
                                          :private_message_id => params[:private_message_id]).first
    if @vis
      if @vis.destroy
        flash[:notice] = "Message successfully removed"
      end
    end
    redirect_to private_messages_path
  end
end
