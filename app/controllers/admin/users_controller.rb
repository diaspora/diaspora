
class Admin::UsersController < Admin::AdminController

  def close_account
    u = User.find(close_account_params)
    u.close_account!
    redirect_to user_search_path, notice: t('admins.user_search.account_closing_scheduled', name: u.username)
  end

  private

  def close_account_params
    params.require(:id)
  end

end
