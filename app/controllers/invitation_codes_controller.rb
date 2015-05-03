class InvitationCodesController < ApplicationController
  before_action :ensure_valid_invite_code

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_url, :notice => "That invite code is no longer valid"
  end

  def show 
    sign_out(current_user) if user_signed_in?
    redirect_to new_user_registration_path(:invite => {:token => params[:id]})
  end

  private

  def ensure_valid_invite_code
    InvitationCode.find_by_token!(params[:id])
  end
end
