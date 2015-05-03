class ParticipationsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = current_user.find_visible_shareable_by_id(Post, params[:post_id])
    if post
      current_user.participate! post
      render nothing: true, status: :created
    else
      render nothing: true, status: :forbidden
    end
  end

  def destroy
    participation = current_user.participations.find_by target_id: params[:post_id]
    if participation
      participation.destroy
      render nothing: true, status: :ok
    else
      render nothing: true, status: :unprocessable_entity
    end
  end
end
