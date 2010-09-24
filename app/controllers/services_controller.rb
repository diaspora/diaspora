#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class ServicesController < ApplicationController

  def create
    puts 'services/create'
    p params

    code = params['code'] # Facebooks verification string
    if code
      access_token_hash = MiniFB.oauth_access_token(FB_APP_ID, APP_CONFIG[:pod_url] + "services/create", FB_SECRET, code)
      p access_token_hash
      @access_token = access_token_hash["access_token"]

      # TODO: This is where you'd want to store the token in your database
      # but for now, we'll just keep it in the session so we don't need a database
      env['warden'].session[:access_token] = @access_token
      flash[:success] = "Authentication successful."
    end
    redirect_to edit_user_url current_user
  end

  def destroy
    env['warden'].session[:access_token] = nil
		env['warden'].session[:user_id] = nil
    redirect_to edit_user_url current_user
  end

  def fb_post
    id = 'me'
    type = 'feed'

    @res = MiniFB.post(@access_token, id, :type=>type, :metadata=>true, :params=>params)
    redirect_to edit_user_url current_user
  end

end
