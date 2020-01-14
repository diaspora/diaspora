# frozen_string_literal: true

class TwoFactorAuthenticationsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_otp_required, only: [:create]

  def show
    @user = current_user
  end

  def create
    current_user.otp_secret = User.generate_otp_secret(32)
    current_user.save!
    redirect_to confirm_two_factor_authentication_path
  end

  def confirm_2fa
    redirect_to two_factor_authentication_path if current_user.otp_required_for_login?
  end

  def confirm_and_activate_2fa
    if current_user.validate_and_consume_otp!(params[:user][:code])
      current_user.otp_required_for_login = true
      current_user.save!

      flash[:notice] = t("two_factor_auth.flash.success_activation")
      redirect_to recovery_codes_two_factor_authentication_path
    else
      flash[:alert] = t("two_factor_auth.flash.error_token")
      redirect_to confirm_two_factor_authentication_path
    end
  end

  def recovery_codes
    @recovery_codes = current_user.generate_otp_backup_codes!
    current_user.save!
  end

  def destroy
    if current_user.valid_password?(params[:two_factor_authentication][:password])
      current_user.otp_required_for_login = false
      current_user.save!
      flash[:notice] = t("two_factor_auth.flash.success_deactivation")
    else
      flash[:alert] = t("users.destroy.wrong_password")
    end
    redirect_to two_factor_authentication_path
  end

  private

  def verify_otp_required
    redirect_to two_factor_authentication_path if current_user.otp_required_for_login?
  end
end
