class UsersController < ApplicationController


  def index
    @users = User.criteria.all.order_by( [:created_at, :desc] )
  end

end
