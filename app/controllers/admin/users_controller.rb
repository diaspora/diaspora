# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    before_action :validate_user, only: %i(make_admin remove_admin make_moderator remove_moderator make_spotlight remove_spotlight)

    # Receives the user ID to lock an account
    def lock_account
      u = User.find(params[:id])
      u.lock_access!
      redirect_to user_search_path, notice: t("admins.user_search.account_locking_scheduled", name: u.username)
    end

    # Receives the user ID to unlock an account
    def unlock_account
      u = User.find(params[:id])
      u.unlock_access!
      redirect_to user_search_path, notice: t("admins.user_search.account_unlocking_scheduled", name: u.username)
    end

    # Receives the person ID to close an account
    def close_account
      p = Person.find(params[:id])
      p.close_account!
      redirect_to user_search_path, notice: t("admins.user_search.account_closing_scheduled", name: p.username)
    end

    # Closes a remote or local account irretrievable and retracts and deletes all created data
    def wipe_and_close_account
      p = Person.find(params[:id])
      p.wipe_and_close_account!
      redirect_to user_search_path, notice: t("admins.user_search.account_closing_scheduled", name: p.username)
    end

    def make_admin
      unless Role.is_admin? @user.person
        Role.add_admin @user.person
        notice = "admins.user_search.add_admin"
      else
        notice = "admins.user_search.role_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    def remove_admin
      return if @user == @current_user

      if Role.is_admin? @user.person
        Role.remove_admin @user.person
        notice = "admins.user_search.delete_admin"
      else
        notice = "admins.user_search.role_removal_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    def make_moderator
      unless Role.moderator_only? @user.person
        Role.add_moderator @user.person
        notice = "admins.user_search.add_moderator"
      else
        notice = "admins.user_search.role_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    def remove_moderator
      if Role.moderator_only? @user.person
        Role.remove_moderator @user.person
        notice = "admins.user_search.delete_moderator"
      else
        notice = "admins.user_search.role_removal_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    def make_spotlight
      unless Role.spotlight? @user.person
        Role.add_spotlight @user.person
        notice = "admins.user_search.add_spotlight"
      else
        notice = "admins.user_search.role_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    def remove_spotlight
      if Role.spotlight? @user.person
        Role.remove_spotlight @user.person
        notice = "admins.user_search.delete_spotlight"
      else
        notice = "admins.user_search.role_removal_implemented"
      end
      redirect_to user_search_path, notice: t(notice, name: @user.username)
    end

    private

    def validate_user
      @user = User.where(id: params[:id]).first
      redirect_to user_search_path, notice: t("admins.user_search.does_not_exist") unless @user
    end
  end
end
