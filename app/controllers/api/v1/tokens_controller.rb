class Api::V1::TokensController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!

  respond_to :json

  def create
    current_user.ensure_authentication_token!
    render :status => 200, :json => { :token => current_user.authentication_token }
  end
  
  def destroy
    current_user.reset_authentication_token!
    render :json => true, :status => 200
  end
end
