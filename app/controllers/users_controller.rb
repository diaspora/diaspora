class UsersController < ApplicationController

  before_filter :authenticate_user!

  def index
    @users = User.criteria.all.order_by( [:created_at, :desc] )
  end

end
