#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registrations_open!

  def create
    @user = User.build(params[:user])
    if @user.save
      flash[:notice] = I18n.t 'registrations.create.success'
      @user.seed_aspects
      sign_in_and_redirect(:user, @user)
      Rails.logger.info("event=registration status=successful user=#{@user.diaspora_handle}")
    else
      @user.errors.delete(:person)

      flash[:error] = @user.errors.full_messages.join(";")
      Rails.logger.info("event=registration status=failure errors='#{@user.errors.full_messages.join(', ')}'")
      render :new
    end
  end

  def new
    super
  end

  #
  # POST: /user/sign_up/by_email
  #
  def sign_in_by_email
    # Find or create user
    user_email = params[:email]
    if user_email.nil?  
      return render :text => "No email address provided"
    end
    # Search by email
    @user = User.where(:email => user_email).first
    if @user.nil?
      puts "No user found by email: #{user_email}"
      puts "Creating new user"
      # Create
      @user = User.create({})
    end
    
    render :text => "foo"
  end
  
  
  private
  def check_registrations_open!
    if AppConfig[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end
end
