class TokensController < ApplicationController
  before_filter :redirect_unless_tokenable
  def redirect_unless_tokenable
    redirect_to root_url unless current_user.auth_tokenable?
  end

  def create
    current_user.reset_authentication_token!
    current_user.authentication_token
    redirect_to token_path, :notice => "Authentication token reset."
  end
end
