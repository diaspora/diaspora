class Users::PasswordController < ApplicationController
  before_filter :authenticate_user!

  def update
    if current_user.update_with_password( user_params )
      redirect_to new_user_session_path, notice: I18n.t('users.update.password_changed')
    else
      redirect_to edit_user_path, error: I18n.t('users.update.password_not_changed')
    end
  end

  private

  def user_params
    params.fetch(:user).permit(
      :current_password,
      :password,
      :password_confirmation
    )
  end
end