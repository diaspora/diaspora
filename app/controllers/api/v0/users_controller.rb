class Api::V0::UsersController < Api::V0::BaseController

  def show
    render json: user
  end

private
  def user
    current_token.o_auth_application.user
  end
end
