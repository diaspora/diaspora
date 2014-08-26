module Admin
  class AdminController < ApplicationController

    before_filter :authenticate_user!
    before_filter :redirect_unless_admin

  end
end
