class UserApplicationsController < ApplicationController
  before_action :authenticate_user!

  def show
    respond_to do |format|
      format.all { @user_apps = UserApplicationsPresenter.new current_user }
    end
  end
end
