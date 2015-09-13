class Api::V2::BaseController < ApplicationController
  include Openid::Authentication

  before_action :authenticate_user!
  before_filter :require_access_token
end
