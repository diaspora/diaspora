class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_account
    @current_account ||= session[:account_id] && Account.find_by_id(session[:account_id])
  end

  helper_method :current_account

  private

  def authenticate_account
    unless current_account
      session[:return_url] = request.request_uri
      redirect_to new_session_url
    end
  end
end
