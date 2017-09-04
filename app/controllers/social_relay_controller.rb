# frozen_string_literal: true

class SocialRelayController < ApplicationController
  respond_to :json

  def well_known
    render json: SocialRelayPresenter.new
  end
end
