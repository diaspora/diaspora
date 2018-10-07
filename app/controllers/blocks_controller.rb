# frozen_string_literal: true

class BlocksController < ApplicationController
  before_action :authenticate_user!

  def create
    block = current_user.blocks.new(block_params)

    send_message(block) if block.save

    respond_to do |format|
      format.json { head :no_content }
      format.any { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    block = current_user.blocks.find_by(id: params[:id])
    notice = if block&.delete
               ContactRetraction.for(block).defer_dispatch(current_user)
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

  def send_message(block)
    contact = current_user.contact_for(block.person)

    if contact
      current_user.disconnect(contact)
    elsif block.person.remote?
      Diaspora::Federation::Dispatcher.defer_dispatch(current_user, block)
    end
  end

  def block_params
    params.require(:block).permit(:person_id)
  end
end
