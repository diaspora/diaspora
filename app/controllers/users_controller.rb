#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:new, :create, :public, :user_photo]
  respond_to :html

  def edit
    @aspect = :user_edit
    @user = current_user
    set_email_preferences
  end

  def privacy_settings
    @blocks = current_user.blocks.includes(:person)
  end

  def update
    password_changed = false
    @user = current_user

    if u = user_params

      # change email notifications
      if u[:email_preferences]
        @user.update_user_preferences(u[:email_preferences])
        flash[:notice] = I18n.t 'users.update.email_notifications_changed'
      # change password
      elsif params[:change_password]
        if @user.update_with_password(u)
          password_changed = true
          flash[:notice] = I18n.t 'users.update.password_changed'
        else
          flash[:error] = I18n.t 'users.update.password_not_changed'
        end
      elsif u[:show_community_spotlight_in_stream] || u[:getting_started]
        if @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.settings_updated'
        else
          flash[:notice] = I18n.t 'users.update.settings_not_updated'
        end
      elsif u[:strip_exif]
        if @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.settings_updated'
        else
          flash[:notice] = I18n.t 'users.update.settings_not_updated'
        end
      elsif u[:language]
        if @user.update_attributes(u)
          I18n.locale = @user.language
          flash[:notice] = I18n.t 'users.update.language_changed'
        else
          flash[:error] = I18n.t 'users.update.language_not_changed'
        end
      elsif u[:email]
        @user.unconfirmed_email = u[:email]
        if @user.save
          @user.send_confirm_email
          if @user.unconfirmed_email
            flash[:notice] = I18n.t 'users.update.unconfirmed_email_changed'
          end
        else
          flash[:error] = I18n.t 'users.update.unconfirmed_email_not_changed'
        end
      elsif u[:auto_follow_back]
        if  @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.follow_settings_changed'
        else
          flash[:error] = I18n.t 'users.update.follow_settings_not_changed'
        end
      elsif u[:color_theme]
        if @user.update_attributes(u)
          flash[:notice] = I18n.t "users.update.color_theme_changed"
        else
          flash[:error] = I18n.t "users.update.color_theme_not_changed"
        end
      end
    end
    set_email_preferences

    respond_to do |format|
      format.js   { render :nothing => true, :status => 204 }
      format.all  do
        if password_changed
          redirect_to new_user_session_path
        else
          render :edit
        end
      end
    end
  end

  def destroy
    if params[:user] && params[:user][:current_password] && current_user.valid_password?(params[:user][:current_password])
      current_user.close_account!
      sign_out current_user
      redirect_to(stream_path, :notice => I18n.t('users.destroy.success'))
    else
      if params[:user].present? && params[:user][:current_password].present?
        flash[:error] = t 'users.destroy.wrong_password'
      else
        flash[:error] = t 'users.destroy.no_password'
      end
      redirect_to :back
    end
  end

  def public
    if @user = User.find_by_username(params[:username])
      respond_to do |format|
        format.atom do
          @posts = Post.where(author_id: @user.person_id, public: true)
                    .order('created_at DESC')
                    .limit(25)
                    .map {|post| post.is_a?(Reshare) ? post.absolute_root : post }
                    .compact
        end

        format.any { redirect_to person_path(@user.person) }
      end
    else
      redirect_to stream_path, :error => I18n.t('users.public.does_not_exist', :username => params[:username])
    end
  end

  def getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile

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
    flash[:notice] = I18n.t('users.edit.export_in_progress')
    redirect_to edit_user_path
  end

  def download_profile
    redirect_to current_user.export.url
  end

  def export_photos
    current_user.queue_export_photos
    flash[:notice] = I18n.t('users.edit.export_photos_in_progress')
    redirect_to edit_user_path
  end

  def download_photos
    redirect_to current_user.exported_photos_file.url
  end

  def user_photo
    username = params[:username].split('@')[0]
    user = User.find_by_username(username)
    if user.present?
      redirect_to user.image_url
    else
      render :nothing => true, :status => 404
    end
  end

  def confirm_email
    if current_user.confirm_email(params[:token])
      flash[:notice] = I18n.t('users.confirm_email.email_confirmed', :email => current_user.email)
    elsif current_user.unconfirmed_email.present?
      flash[:error] = I18n.t('users.confirm_email.email_not_confirmed')
    end
    redirect_to edit_user_path
  end

  private

  def user_params
    params.fetch(:user).permit(
      :email,
      :current_password,
      :password,
      :password_confirmation,
      :language,
      :color_theme,
      :disable_mail,
      :invitation_service,
      :invitation_identifier,
      :show_community_spotlight_in_stream,
      :strip_exif,
      :auto_follow_back,
      :auto_follow_back_aspect_id,
      :remember_me,
      :getting_started,
      email_preferences: [
        :someone_reported,
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

  def set_email_preferences
    @email_prefs = Hash.new(true)

    @user.user_preferences.each do |pref|
      @email_prefs[pref.email_type] = false
    end
  end
end
