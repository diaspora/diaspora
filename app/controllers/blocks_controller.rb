class BlocksController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def create
    block = current_user.blocks.new(block_params)

    disconnect_if_contact(block.person) if block.save

    respond_with do |format|
      format.json { head :no_content }
    end
  end

  def destroy
    current_user.blocks.find(params[:id]).delete

    respond_with do |format|
      format.json { head :no_content }
    end
  end

  private

  def disconnect_if_contact(person)
    current_user.contact_for(person).try {|contact| current_user.disconnect(contact) }
  end

  def block_params
    params.require(:block).permit(:person_id)
  end
end
