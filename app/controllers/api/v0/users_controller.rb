class Api::V0::UsersController < Api::V0::BaseController
  def show
    render json: user
  end

  private

  def user
    authorization.user
  end
end
