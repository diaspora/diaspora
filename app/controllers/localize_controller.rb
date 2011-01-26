class LocalizeController < ApplicationController
  before_filter :authenticate_user!

  include LocalizeHelper

  def show
    if current_user
      render :json => localize current_user.language
    else
      redirect_to aspects_path
    end
  end
end