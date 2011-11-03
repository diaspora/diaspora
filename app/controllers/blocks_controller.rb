class BlocksController < ApplicationController
  before_filter :authenticate_user!

  def create
    current_user.blocks.create(params[:block])
    redirect_to :back, :notice => "that person sucked anyways..."
  end

  def destroy
    current_user.blocks.find(params[:id]).delete
    redirect_to :back, :notice => "MAKE UP YOUR MIND."
  end
end
