#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class ServicesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @services = current_user.services
  end

  def create
    auth = request.env['omniauth.auth']

    provider = auth['provider']
    user     = auth['user_info']

    if provider == 'twitter'
      access_token = auth['extra']['access_token']
      current_user.services.create(:nickname => user['nickname'],
                                   :access_token => access_token.token, 
                                   :access_secret => access_token.secret,
                                   :provider => provider, 
                                   :uid => auth['uid'])
                                   
    elsif provider == 'facebook'
      current_user.services.create(:nickname => user['nickname'],
                                   :access_token => auth['credentials']['token'],
                                   :provider => provider, 
                                   :uid => auth['uid'])
    end


    flash[:notice] = "Authentication successful."
    redirect_to services_url
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to services_url
  end
end
