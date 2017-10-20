# frozen_string_literal: true

module Api
  module OpenidConnect
    class UserApplicationsController < ApplicationController
      before_action :authenticate_user!

      def index
        @user_apps = UserApplicationsPresenter.new current_user
      end
    end
  end
end
