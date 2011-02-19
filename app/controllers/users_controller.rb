#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
class UsersController < ApplicationController
  require File.join(Rails.root, 'lib/diaspora/ostatus_builder')
  require File.join(Rails.root, 'lib/diaspora/exporter')
  require File.join(Rails.root, 'lib/collect_user_photos')

  before_filter :authenticate_user!, :except => [:new, :create, :public]

  respond_to :html

  def edit
    @aspect = :user_edit
    @user   = current_user
  end

  def update
    @user = current_user

    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    params[:user].delete(:language) if params[:user][:language].blank?

    # change email notifications
    if params[:user][:disable_mail]
      @user.update_attributes(:disable_mail => params[:user][:disable_mail])
      flash[:notice] = I18n.t 'users.update.email_notifications_changed'
    # change passowrd
    elsif params[:user][:current_password] && params[:user][:password] && params[:user][:password_confirmation]
      if @user.update_with_password(params[:user])
        flash[:notice] = I18n.t 'users.update.password_changed'
      else
        flash[:error] = I18n.t 'users.update.password_not_changed'
      end
    elsif params[:user][:language]
      if @user.update_attributes(:language => params[:user][:language])
        I18n.locale = @user.language
        flash[:notice] = I18n.t 'users.update.language_changed'
      else
        flash[:error] = I18n.t 'users.update.language_not_changed'
      end
    elsif params[:user][:a_ids]
      @user.aspects.update_all(:open => false)
      unless params[:user][:a_ids] == ["home"]
        @user.aspects.where(:id => params[:user][:a_ids]).update_all(:open => true)
      end
    end

    respond_to do |format|
      format.js{
        render :nothing => true, :status => 204
      }
      format.all{
        redirect_to edit_user_path(@user)
      }
    end
  end

  def destroy
    current_user.destroy
    sign_out current_user
    flash[:notice] = I18n.t 'users.destroy'
    redirect_to root_path
  end

  def public
    user = User.find_by_username(params[:username])

    if user
      director = Diaspora::Director.new
      ostatus_builder = Diaspora::OstatusBuilder.new(user)

      render :xml => director.build(ostatus_builder), :content_type => 'application/atom+xml'
    else
      flash[:error] = I18n.t 'users.public.does_not_exist', :username => params[:username]
      redirect_to root_url
    end
  end

  def getting_started
    @aspect   = :getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile
    @services = @user.services
    service = current_user.services.where(:type => "Services::Facebook").first

    @step = ((params[:step].to_i>0)&&(params[:step].to_i<4)) ? params[:step].to_i : 1
    @step ||= 1

    if @step == 2 && SERVICES['facebook']['app_id'] == ""
      @step = 3
    end

    if @step == 3
      @requests = Request.where(:recipient_id => @person.id).includes(:sender => :profile).all
      @friends = service ? service.finder(:local => true) : {}
      @friends.delete_if{|key, value| @requests.any?{ |r| r.sender_id == value[:person].id} }
    end


    if @step == 3 && @requests.length == 0 && @friends.length == 0
      @user.update_attributes(:getting_started => false)
      redirect_to root_path
    else
      render "users/getting_started"
    end
  end

  def getting_started_completed
    user = current_user
    user.update_attributes(:getting_started => false)
    redirect_to root_path
  end

  def export
    exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
    send_data exporter.execute(current_user), :filename => "#{current_user.username}_diaspora_data.xml", :type => :xml
  end

  def export_photos
    tar_path = PhotoMover::move_photos(current_user)
    send_data( File.open(tar_path).read, :filename => "#{current_user.id}.tar" )
  end
end
