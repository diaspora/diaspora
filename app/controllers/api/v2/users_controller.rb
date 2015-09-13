class Api::V2::UsersController < Api::V2::BaseController
  def show
    render json: current_user
  end
end
