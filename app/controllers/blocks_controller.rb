# frozen_string_literal: true

class BlocksController < ApplicationController
  before_action :authenticate_user!

  def create
    begin
      block_service.block(Person.find_by!(id: block_params[:person_id]))
    rescue ActiveRecord::RecordNotUnique
    end

    respond_to do |format|
      format.json { head :no_content }
      format.any { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    notice = nil
    begin
      block_service.remove_block(current_user.blocks.find_by!(id: params[:id]))
      notice = {notice: t("blocks.destroy.success")}
    rescue ActiveRecord::RecordNotFound
      notice = {error: t("blocks.destroy.failure")}
    end

    respond_to do |format|
      format.json { head :no_content }
      format.any { redirect_back fallback_location: privacy_settings_path, flash: notice }
    end
  end

  private

  def block_params
    params.require(:block).permit(:person_id)
  end

  def block_service
    BlockService.new(current_user)
  end
end
