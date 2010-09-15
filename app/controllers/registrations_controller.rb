#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    User.instantiate!(params[:user])
    redirect_to root_url
  end

  def update
    super
  end
end
