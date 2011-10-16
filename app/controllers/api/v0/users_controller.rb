#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Api::V0::UsersController < ApplicationController
  def show
    if user = User.find_by_username(params[:username])
      render :json => Api::V0::Serializers::User.new(user)
    else
      head :not_found
    end
  end
end
