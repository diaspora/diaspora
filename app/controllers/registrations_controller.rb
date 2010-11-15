#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registrations_open!

  def create
    @user = User.build(params[:user])
    if @user.save
      flash[:notice] = I18n.t 'registrations.create.success'
      @user.seed_aspects
      sign_in_and_redirect(:user, @user)
    else
      flash[:error] = @user.errors.full_messages.join(', ')
      render :new
    end
  end

  def new
    super
  end

  private
  def check_registrations_open!
    if APP_CONFIG[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to root_url
    end
  end
end
