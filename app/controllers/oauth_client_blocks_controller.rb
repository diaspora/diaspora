#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class OauthClientBlocksController < ApplicationController

  before_filter :authenticate_user!

  respond_to :html

  def update
    @user = current_user

    if @user.set_oauth_client_blocks( params['application_blocks'] )
      flash[:notice] = I18n.t('users.update.application_blocks_update.success')
    else
      flash[:error] = I18n.t('users.update.application_blocks_update.failure')
    end

    redirect_to authorizations_path
  end

end
