# frozen_string_literal: true

module Admin
  class UsersController < AdminController

    def close_account
      u = User.find(params[:id])
      u.close_account!
      redirect_to user_search_path, notice: t("admins.user_search.account_closing_scheduled", name: u.username)
    end

    def lock_account
      u = User.find(params[:id])
      u.lock_access!
      redirect_to user_search_path, notice: t("admins.user_search.account_locking_scheduled", name: u.username)
    end

    def unlock_account
      u = User.find(params[:id])
      u.unlock_access!
      redirect_to user_search_path, notice: t("admins.user_search.account_unlocking_scheduled", name: u.username)
    end

  end
end
