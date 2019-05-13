# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :authenticate_with_2fa, only: :create
  after_action :reset_authentication_token, only: :create
  before_action :reset_authentication_token, only: :destroy
  # rubocop:enable Rails/LexicallyScopedActionFilter

  def find_user
    return User.find(session[:otp_user_id]) if session[:otp_user_id]

    User.find_for_authentication(username: params[:user][:username]) if params[:user][:username]
  end

  def authenticate_with_2fa
    self.resource = find_user
    u = find_user

    return true unless u&.otp_required_for_login?

    if params[:user][:otp_attempt].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(u)
    elsif u&.valid_password?(params[:user][:password])
      prompt_for_two_factor(u)
    end
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(params[:user][:otp_attempt]) ||
      user.invalidate_otp_backup_code!(params[:user][:otp_attempt])
  rescue OpenSSL::Cipher::CipherError => _error
    false
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      session.delete(:otp_user_id)
      sign_in(user)
    else
      flash.now[:alert] = "Invalid token"
      prompt_for_two_factor(user)
    end
  end

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    render :two_factor
  end

  def reset_authentication_token
    current_user&.reset_authentication_token!
  end
end
