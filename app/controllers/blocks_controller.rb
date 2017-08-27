# frozen_string_literal: true

class BlocksController < ApplicationController
  before_action :authenticate_user!

  def create
    block = current_user.blocks.new(block_params)

    disconnect_if_contact(block.person) if block.save

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def destroy
    notice = if current_user.blocks.find_by(id: params[:id])&.delete
               {notice: t("blocks.destroy.success")}
             else
               {error: t("blocks.destroy.failure")}
             end

    respond_to do |format|
      format.json { head :no_content }
      format.any { redirect_back fallback_location: privacy_settings_path, flash: notice }
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
