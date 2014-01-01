class Users::EmailPreferencesController < ApplicationController
  before_filter :authenticate_user!

  def update
    current_user.update_user_preferences( user_params[:email_preferences] )

    redirect_to edit_user_path, notice: I18n.t( 'users.update.email_notifications_changed' )
  end

  private

  def user_params
    params.fetch(:user).permit(
      email_preferences: [
        :also_commented,
        :mentioned,
        :comment_on_post,
        :private_message,
        :started_sharing,
        :liked,
        :reshared
      ]
    )
  end
end
