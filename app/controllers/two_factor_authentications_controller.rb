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
    @qrcode_uri = qrcode_uri
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
    if acceptable_code?
      current_user.otp_required_for_login = false
      current_user.save!
      flash[:notice] = t("two_factor_auth.flash.success_deactivation")
    else
      flash.now[:alert] = t("two_factor_auth.flash.error_token")
    end
    redirect_to two_factor_authentication_path
  end

  private

  def qrcode_uri
    pod = AppConfig.environment.url
    label = "#{pod} #{current_user.username}"
    current_user.otp_provisioning_uri(label, issuer: pod)
  end

  def verify_otp_required
    redirect_to two_factor_authentication_path if current_user.otp_required_for_login?
  end

  def acceptable_code?
    current_user.validate_and_consume_otp!(params[:two_factor_authentication][:code]) ||
      current_user.invalidate_otp_backup_code!(params[:two_factor_authentication][:code])
  end
end
