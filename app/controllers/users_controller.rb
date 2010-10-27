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
      puts "here"
      boolean = params[:user][:getting_started] == "true"
      @user.update_attributes( :getting_started => boolean )
      redirect_to root_path

    else
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?

      if params[:user][:password] && params[:user][:password_confirmation]
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          flash[:notice] = "Password Changed"
        else
          flash[:error] = "Password Change Failed"
        end
      end
    end

    redirect_to edit_user_path(@user)
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
    @photos   = @user.visible_posts(:person_id => current_user.person.id, :_type => 'Photo').paginate :page => params[:page], :order => 'created_at DESC'
    @services = @user.services

    @step = ((params[:step].to_i>0)&&(params[:step].to_i<5)) ? params[:step].to_i : 1
    @step ||= 1
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

    params[:user][:diaspora_handle] = 'asodij@asodij.asd'


    begin
      importer = Diaspora::Importer.new(Diaspora::Parsers::XML)
      importer.execute(xml, params[:user])
      flash[:notice] = "hang on a sec, try logging in!"

    rescue Exception => e
      flash[:error] = "Derp, something went wrong: #{e.message}"
    end

      redirect_to new_user_registration_path
    #redirect_to user_session_path
  end



end
