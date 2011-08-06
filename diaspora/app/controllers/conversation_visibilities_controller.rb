#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class ConversationVisibilitiesController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    @vis = ConversationVisibility.where(:person_id => current_user.person.id,
                                        :conversation_id => params[:conversation_id]).first
    if @vis
      if @vis.destroy
        flash[:notice] = I18n.t('conversations.destroy.success')
      end
    end
    redirect_to conversations_path
  end
end
