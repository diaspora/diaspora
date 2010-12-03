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

    toke = auth['credentials']['token']
    secret = auth['credentials']['secret']

    provider = auth['provider']
    user     = auth['user_info']

    current_user.services.create(:nickname => user['nickname'],
                                 :access_token => toke, 
                                 :access_secret => secret,
                                 :provider => provider, 
                                 :uid => auth['uid'])

    flash[:notice] = I18n.t 'services.create.success'
    if current_user.getting_started
      redirect_to  getting_started_path(:step => 3)
    else
      redirect_to services_url 
    end
  end


  def failure
    Rails.logger.info  "error in oauth #{params.inspect}"
    flash[:error] = "there was an error connecting that service"
    redirect_to services_url
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.destroy
    flash[:notice] = I18n.t 'services.destroy.success'
    redirect_to services_url
  end
end
