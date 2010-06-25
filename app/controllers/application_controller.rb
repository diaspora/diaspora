class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :set_user
  def set_user
    @user = current_user
    true
  end

  protect_from_forgery :except => :receive
  layout 'application'

end
