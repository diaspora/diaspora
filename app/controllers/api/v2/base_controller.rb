class Api::V2::BaseController < ApplicationController
  include OpenidConnect::Authentication

  before_filter :require_access_token
end
