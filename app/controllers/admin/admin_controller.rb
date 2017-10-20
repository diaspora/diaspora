# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :redirect_unless_admin
  end
end
