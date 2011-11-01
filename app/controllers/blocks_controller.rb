class BlocksController < ApplicationController
  before_filter :authenticate_user!

  def create
    current_user.blocks.create(params[:block])

    redirect_to :back, :notice => "that person sucked anyways..."
  end
end