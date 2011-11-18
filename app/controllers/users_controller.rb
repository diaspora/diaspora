#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
  require File.join(Rails.root, 'lib/diaspora/ostatus_builder')
  require File.join(Rails.root, 'lib/diaspora/exporter')
  require File.join(Rails.root, 'lib/collect_user_photos')

  before_filter :authenticate_user!, :except => [:new, :create, :public, :user_photo, :logged_out]

  respond_to :html

  def edit
    @aspect = :user_edit
    @user   = current_user
    @email_prefs = Hash.new(true)
    @user.user_preferences.each do |pref|
      @email_prefs[pref.email_type] = false
    end
  end

  def privacy_settings
    @blocks = current_user.blocks.includes(:person)
  end

  def update
    password_changed = false
    @user = current_user

    if u = params[:user]
      u.delete(:password) if u[:password].blank?
      u.delete(:password_confirmation) if u[:password].blank? and u[:password_confirmation].blank?
      u.delete(:language) if u[:language].blank?

      # change email notifications
      if u[:email_preferences]
        @user.update_user_preferences(u[:email_preferences])
        flash[:notice] = I18n.t 'users.update.email_notifications_changed'
      # change password
      elsif u[:current_password] && u[:password] && u[:password_confirmation]
        if @user.update_with_password(u)
          password_changed = true
          flash[:notice] = I18n.t 'users.update.password_changed'
        else
          flash[:error] = I18n.t 'users.update.password_not_changed'
        end
      elsif u[:show_community_spotlight_in_stream] || u[:getting_started]
        if @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.settings_updated'
          redirect_to multi_path
          return
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
          @user.mail_confirm_email
          flash[:notice] = I18n.t 'users.update.unconfirmed_email_changed'
        else
          flash[:error] = I18n.t 'users.update.unconfirmed_email_not_changed'
        end
      end
    elsif aspect_order = params[:reorder_aspects]
      @user.reorder_aspects(aspect_order)
    end

    respond_to do |format|
      format.js   { render :nothing => true, :status => 204 }
      format.all  { redirect_to password_changed ? new_user_session_path : edit_user_path }
    end
  end

  def destroy
    if params[:user] && params[:user][:current_password] && current_user.valid_password?(params[:user][:current_password])
      Resque.enqueue(Jobs::DeleteAccount, current_user.id)
      current_user.lock_access!
      sign_out current_user
      flash[:notice] = I18n.t 'users.destroy.success'
      redirect_to root_path
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
    if user = User.find_by_username(params[:username])
      respond_to do |format|
        format.atom do
          posts = StatusMessage.where(:author_id => user.person.id, :public => true).order('created_at DESC').limit(25)
          director = Diaspora::Director.new
          ostatus_builder = Diaspora::OstatusBuilder.new(user, posts)
          render :xml => director.build(ostatus_builder), :content_type => 'application/atom+xml'
        end

        format.any { redirect_to person_path(user.person.id) }
      end
    else
      redirect_to multi_path, :error => I18n.t('users.public.does_not_exist', :username => params[:username])
    end
  end

  def getting_started
    @aspect   = :getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile

    render "users/getting_started"
  end

  def logged_out
    @page = :logged_out
    if user_signed_in?
      redirect_to multi_path
    end
  end

  def getting_started_completed
    user = current_user
    user.update_attributes(:getting_started => false)
    redirect_to multi_path
  end

  def export
    exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
    send_data exporter.execute(current_user), :filename => "#{current_user.username}_diaspora_data.xml", :type => :xml
  end

  def export_photos
    tar_path = PhotoMover::move_photos(current_user)
    send_data( File.open(tar_path).read, :filename => "#{current_user.id}.tar" )
  end

  def user_photo
    username = params[:username].split('@')[0]
    user = User.find_by_username(username)
    if user.present?
      redirect_to user.profile.image_url
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
end
