# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i(new create public)
  respond_to :html

  def edit
    @user = current_user
    set_email_preferences
  end

  def privacy_settings
    @blocks = current_user.blocks.includes(:person)
  end

  def update
    password_changed = false
    user_data = user_params
    @user = current_user

    if user_data
      # change password
      if params[:change_password]
        password_changed = change_password(user_data)
      else
        update_user(user_data)
      end
    end

    if password_changed
      redirect_to new_user_session_path
    else
      set_email_preferences
      render :edit
    end
  end

  def update_privacy_settings
    privacy_params = params.fetch(:user).permit(:strip_exif)

    if current_user.update_attributes(strip_exif: privacy_params[:strip_exif])
      flash[:notice] = t("users.update.settings_updated")
    else
      flash[:error] = t("users.update.settings_not_updated")
    end

    redirect_back fallback_location: privacy_settings_path
  end

  def destroy
    if params[:user] && params[:user][:current_password] && current_user.valid_password?(params[:user][:current_password])
      current_user.close_account!
      sign_out current_user
      redirect_to(new_user_session_path(format: request[:format]), notice: I18n.t("users.destroy.success"))
    else
      if params[:user].present? && params[:user][:current_password].present?
        flash[:error] = t "users.destroy.wrong_password"
      else
        flash[:error] = t "users.destroy.no_password"
      end
      redirect_back fallback_location: edit_user_path
    end
  end

  def public
    if @user = User.find_by_username(params[:username])
      respond_to do |format|
        format.atom do
          @posts = Post.where(author_id: @user.person_id, public: true)
                       .order("created_at DESC")
                       .limit(25)
                       .map {|post| post.is_a?(Reshare) ? post.absolute_root : post }
                       .compact
        end

        format.any { redirect_to person_path(@user.person) }
      end
    else
      redirect_to stream_path, error: I18n.t("users.public.does_not_exist", username: params[:username])
    end
  end

  def getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile
    gon.preloads[:inviter] = PersonPresenter.new(current_user.invited_by.try(:person), current_user).as_json
    gon.preloads[:tagsArray] = current_user.followed_tags.map {|tag| {name: "##{tag.name}", value: "##{tag.name}"} }

    render "users/getting_started"
  end

  def getting_started_completed
    user = current_user
    user.getting_started = false
    user.save
    redirect_to stream_path
  end

  def export_profile
    current_user.queue_export
    flash[:notice] = I18n.t("users.edit.export_in_progress")
    redirect_to edit_user_path
  end

  def download_profile
    redirect_to current_user.export.url
  end

  def export_photos
    current_user.queue_export_photos
    flash[:notice] = I18n.t("users.edit.export_photos_in_progress")
    redirect_to edit_user_path
  end

  def download_photos
    redirect_to current_user.exported_photos_file.url
  end

  def confirm_email
    if current_user.confirm_email(params[:token])
      flash[:notice] = I18n.t("users.confirm_email.email_confirmed", email: current_user.email)
    elsif current_user.unconfirmed_email.present?
      flash[:error] = I18n.t("users.confirm_email.email_not_confirmed")
    end
    redirect_to edit_user_path
  end

  def auth_token
    current_user.ensure_authentication_token!
    render status: 200, json: {token: current_user.authentication_token}
  end

  private

  # rubocop:disable Metrics/MethodLength
  def user_params
    params.fetch(:user).permit(
      :email,
      :current_password,
      :password,
      :password_confirmation,
      :language,
      :color_theme,
      :disable_mail,
      :show_community_spotlight_in_stream,
      :auto_follow_back,
      :auto_follow_back_aspect_id,
      :getting_started,
      :post_default_public,
      email_preferences: UserPreference::VALID_EMAIL_TYPES.map(&:to_sym)
    )
  end
  # rubocop:enable Metrics/MethodLength

  def update_user(user_data)
    if user_data[:email_preferences]
      change_email_preferences(user_data)
    elsif user_data[:language]
      change_language(user_data)
    elsif user_data[:email]
      change_email(user_data)
    elsif user_data[:auto_follow_back]
      change_settings(user_data, "users.update.follow_settings_changed", "users.update.follow_settings_not_changed")
    elsif user_data[:post_default_public]
      change_post_default(user_data)
    elsif user_data[:color_theme]
      change_settings(user_data, "users.update.color_theme_changed", "users.update.color_theme_not_changed")
    else
      change_settings(user_data)
    end
  end

  def change_password(user_data)
    if @user.update_with_password(user_data)
      flash[:notice] = t("users.update.password_changed")
      true
    else
      flash.now[:error] = t("users.update.password_not_changed")
      false
    end
  end

  def change_post_default(user_data)
    # by default user_data[:post_default_public] is set to  false
    case params[:aspect_ids].try(:first)
    when "public"
      user_data[:post_default_public] = true
    when "all_aspects"
      params[:aspect_ids] = @user.aspects.map {|a| a.id.to_s }
    end
    @user.update_post_default_aspects params[:aspect_ids].to_a
    change_settings(user_data)
  end

  # change email notifications
  def change_email_preferences(user_data)
    @user.update_user_preferences(user_data[:email_preferences])
    flash.now[:notice] = t("users.update.email_notifications_changed")
  end

  def change_language(user_data)
    if @user.update_attributes(user_data)
      I18n.locale = @user.language
      flash.now[:notice] = t("users.update.language_changed")
    else
      flash.now[:error] = t("users.update.language_not_changed")
    end
  end

  def change_email(user_data)
    if AppConfig.mail.enable?
      @user.unconfirmed_email = user_data[:email]
      if @user.save
        @user.send_confirm_email
        flash.now[:notice] = t("users.update.unconfirmed_email_changed")
      else
        @user.reload # match user object with the database
        flash.now[:error] = t("users.update.unconfirmed_email_not_changed")
      end
    else
      @user.email = user_data[:email]
      if @user.save
        flash.now[:notice] = t("users.update.settings_updated")
      else
        @user.reload
        flash.now[:error] = t("users.update.unconfirmed_email_not_changed")
      end
    end
  end

  def change_settings(user_data, successful="users.update.settings_updated", error="users.update.settings_not_updated")
    if @user.update_attributes(user_data)
      flash.now[:notice] = t(successful)
    else
      flash.now[:error] = t(error)
    end
  end

  def set_email_preferences
    @email_prefs = Hash.new(true)

    @user.user_preferences.each do |pref|
      @email_prefs[pref.email_type] = false
    end
  end
end
