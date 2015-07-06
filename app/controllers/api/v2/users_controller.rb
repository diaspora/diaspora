class Api::V2::UsersController < Api::V2::BaseController

  def show
    render json: user
  end

private
  def user
    current_token.o_auth_application.user
  end
end
