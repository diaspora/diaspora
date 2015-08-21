class UserApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.all { @user_apps = UserApplicationsPresenter.new current_user }
    end
  end
end
