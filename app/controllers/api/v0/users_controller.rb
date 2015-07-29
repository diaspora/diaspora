class Api::V0::UsersController < Api::V0::BaseController
  before_action do
    require_access_token Api::OpenidConnect::Scope.find_by(name: "read")
  end

  def show
    render json: user
  end
end
