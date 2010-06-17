class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @posts = Post.stream
  end
end
