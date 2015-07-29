class Api::V0::BaseController < ApplicationController
  include Api::OpenidConnect::ProtectedResourceEndpoint

  def user
    current_token ? current_token.authorization.user : nil
  end
end
