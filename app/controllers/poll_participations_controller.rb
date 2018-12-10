# frozen_string_literal: true

class PollParticipationsController < ApplicationController
  before_action :authenticate_user!

  def create
    poll_participation = poll_service.vote(params[:post_id], params[:poll_answer_id])
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

  def poll_service
    @poll_service ||= PollParticipationService.new(current_user)
  end
end
