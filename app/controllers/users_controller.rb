#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
  require File.join(Rails.root, 'lib/diaspora/ostatus_builder')
  require File.join(Rails.root, 'lib/diaspora/exporter')
  require File.join(Rails.root, 'lib/diaspora/importer')
  require File.join(Rails.root, 'lib/collect_user_photos')


  before_filter :authenticate_user!, :except => [:new, :create, :public, :import]

  respond_to :html

  def edit
    @aspect = :user_edit
    @user   = current_user
  end

  def update
    @user = current_user

    if params[:user][:getting_started]
      boolean = params[:user][:getting_started] == "true"
      @user.update_attributes( :getting_started => boolean )
      redirect_to root_path

    else
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
      params[:user].delete(:language) if params[:user][:language].blank?

      if params[:user][:password] && params[:user][:password_confirmation]
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          flash[:notice] = "Password Changed"
        else
          flash[:error] = "Password Change Failed"
        end
      elsif params[:user][:language]
        if @user.update_attributes(:language => params[:user][:language])
          flash[:notice] = "Language Changed"
        else
          flash[:error] = "Language Change Failed"
        end
      end

      redirect_to edit_user_path(@user)
    end
  end

  def destroy
    current_user.destroy
    sign_out current_user
    flash[:notice] = t('user.destroy')
    redirect_to root_path
  end

  def public
    user = User.find_by_username(params[:username])

    if user
      director = Diaspora::Director.new
      ostatus_builder = Diaspora::OstatusBuilder.new(user)

      render :xml => director.build(ostatus_builder), :content_type => 'application/atom+xml'
    else
      flash[:error] = "User #{params[:username]} does not exist!"
      redirect_to root_url
    end
  end

  def getting_started
    @aspect   = :getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile
    @services = @user.services

    @step = ((params[:step].to_i>0)&&(params[:step].to_i<5)) ? params[:step].to_i : 1
    @step ||= 1

    if @step == 4
      @user.getting_started = false
      @user.save
    end
    render "users/getting_started"
  end

  def export
    exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
    send_data exporter.execute(current_user), :filename => "#{current_user.username}_diaspora_data.xml", :type => :xml
  end

  def export_photos
    tar_path = PhotoMover::move_photos(current_user)
    send_data( File.open(tar_path).read, :filename => "#{current_user.id}.tar" )
  end

  def invite
    User.invite!(:email => params[:email])
  end
  
  
  def import
    xml = params[:upload][:file].read

    begin
      importer = Diaspora::Importer.new(Diaspora::Parsers::XML)
      importer.execute(xml, params[:user])
      flash[:notice] = "hang on a sec, try logging in!"

    rescue Exception => e
      flash[:error] = "Something went wrong: #{e.message}"
    end

      redirect_to new_user_registration_path
    #redirect_to user_session_path
  end



end
