class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @posts = Post.recent_ordered_posts
  end
end
