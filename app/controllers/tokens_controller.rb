class TokensController < ApplicationController
  def create
    current_user.reset_authentication_token!
    current_user.authentication_token
    redirect_to token_path, :notice => "Authentication token reset."
  end
  def show
  end
end

