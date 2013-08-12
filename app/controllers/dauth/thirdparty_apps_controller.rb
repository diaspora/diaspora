class Dauth::ThirdpartyAppsController < ApplicationController
  before_filter :authenticate_user!

  def index
    #current users allowed app list
    @dauth_thirdparty_apps = Dauth::ThirdpartyApp.joins(:refresh_tokens).where(:dauth_refresh_tokens => {:user_id =>  current_user.id})
  end

  def show
    @app = Dauth::ThirdpartyApp.joins(:refresh_tokens).where(:dauth_refresh_tokens => {:user_id =>  current_user.id}).find(params[:id])
    @dev = Webfinger.new(@app.dev_handle).fetch
  end

  def destroy
    #revoke allowed apps
    current_user.refresh_tokens.find_by_app_id(params[:id]).destroy
    redirect_to dauth_thirdparty_apps_url
  end
end
