# frozen_string_literal: true

class PollParticipationsController < ApplicationController
  before_action :authenticate_user!

  def create
    answer = PollAnswer.find(params[:poll_answer_id])
    poll_participation = current_user.participate_in_poll!(target, answer) if target
    respond_to do |format|
      format.mobile { redirect_to stream_path }
      format.json { render json: poll_participation, :status => 201 }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.mobile { redirect_to stream_path }
      format.json { head :forbidden }
    end
  end

  private

  def target
    @target ||= if params[:post_id]
      current_user.find_visible_shareable_by_id(Post, params[:post_id]) || raise(ActiveRecord::RecordNotFound.new)
    end
  end
end
