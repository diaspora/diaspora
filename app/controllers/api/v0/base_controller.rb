class Api::V0::BaseController < ApplicationController
  include OpenidConnect::ProtectedResourceEndpoint

  before_filter :require_access_token
end
