class Api::V0::UsersController < ApplicationController
  def show
    if user = User.find_by_username(params[:username])
      render :json => Api::V0::Serializers::User.new(user)
    else
      head :not_found
    end
  end
end
