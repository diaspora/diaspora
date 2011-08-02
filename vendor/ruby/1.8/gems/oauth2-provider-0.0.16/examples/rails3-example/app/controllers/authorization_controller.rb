class AuthorizationController < ApplicationController
  include OAuth2::Provider::Rack::AuthorizationCodesSupport

  before_filter :authenticate_account
  before_filter :block_invalid_authorization_code_requests

  def new
    @client = oauth2_authorization_request.client
  end

  def create
    if params[:commit] == "Yes"
      grant_authorization_code(current_account)
    else
      deny_authorization_code
    end
  end
end