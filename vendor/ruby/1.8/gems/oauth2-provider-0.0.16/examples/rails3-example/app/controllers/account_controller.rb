class AccountController < ApplicationController
  authenticate_with_oauth
  before_filter :set_current_account_from_oauth

  def show
    render :json => {:login => current_account.login}
  end

  private

  def set_current_account_from_oauth
    @current_account = request.env['oauth2'].resource_owner
  end
end