class Api::V0::BaseController < ApplicationController
  include OpenidConnect::ProtectedResourceEndpoint

  before_filter :require_access_token

  def authorization
    current_token.authorization
  end
end
