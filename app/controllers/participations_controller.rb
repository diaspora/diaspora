# frozen_string_literal: true

class ParticipationsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = current_user.find_visible_shareable_by_id(Post, params[:post_id])
    if post
      current_user.participate! post
      head :created
    else
      head :forbidden
    end
  end

  def destroy
    participation = current_user.participations.find_by target_id: params[:post_id]
    if participation
      participation.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
