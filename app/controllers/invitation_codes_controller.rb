# frozen_string_literal: true

class InvitationCodesController < ApplicationController
  before_action :ensure_valid_invite_code

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_url, :notice => I18n.t('invitation_codes.not_valid')
  end

  def show
    if user_signed_in?
      invite = InvitationCode.find_by_token!(params[:id])
      flash[:notice] = I18n.t("invitation_codes.already_logged_in", inviter: invite.user.name)
      redirect_to person_path(invite.user.person)
    else
      redirect_to new_user_registration_path(invite: {token: params[:id]})
    end
  end

  private

  def ensure_valid_invite_code
    InvitationCode.find_by_token!(params[:id])
  end
end
