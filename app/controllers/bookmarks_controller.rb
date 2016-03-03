class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    item = Bookmarks.new(
      user_id: current_user.id,
      post_id: params[:post_id])

    if item.save
      render json: true, status: 200
    else
      render nothing: true, status: 409
    end
  end

  def destroy
    item = Bookmarks.where(
      post_id: params[:post_id],
      user_id: current_user.id).first

    if item.destroy
      render json: true, status: 200
    else
      render nothing: true, status: 409
    end
  end
end
