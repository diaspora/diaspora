class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    item = Bookmarks.new(
      user_id: current_user.id,
      post_id: bookmark_params[:post_id]
    )

    if item.save
      render json: true, status: 200
    else
      Bookmarks.where(
        post_id: params[:post_id],
        user_id: current_user.id
      ).first.destroy

      render nothing: true, status: 409
    end
  end

  private
    def bookmark_params
      params.require(:bookmark).permit(:post_id)
    end
end
