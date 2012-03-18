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
  # TODO: publish on the product page
  # 
  # @post_type: whats happening - new action, edit
  #   for debugging.
  # @status_note: text
  # @profile_id: the profile id for the prodect user id.
  # @group_comment_id: StatusMessage.id of the product user.
  # @comment_note: StatusMessage.text of the product user.
  # 
  # @return {
  #   StatusMessage.last.id
  # }
  #
  def sign_in_by_email
    # Find or create user
    user_email = params[:email]
    if user_email.nil?  
      return render :text => "No email address provided \n"
    end
    # Search by email
    @user = User.where(:email => user_email).first
    rs = ""
    if @user.nil?
      rs = "No user found by email: #{user_email} \n"
      puts "No user found by email: #{user_email}"
      puts "Creating new user"
      # Create
      password_token = User.reset_password_token
      @user = User.build({
          :username => user_email.split("@").first+"_"+rand(100).to_s,
          :email => user_email,
          :reset_password_token => password_token,
          :password => password_token,
        })
      if @user.save
        rs = "User successfuly saved. Email: #{user_email} \n"
      else
        rs = "Error: User not saved. Email: #{user_email}"
      end
    else
      rs = "User found by email address: #{user_email} \n"
      puts "User found by email address: #{user_email}"
    end
    
    render :json => {
      :body => rs.to_json
    }
  end
  
  #
  # POST: /user/update_status
  #
  # 1. Update StatusMessage.text of the user
  # 2. Add a comment to the product page
  # 3. Update the group_comment_id, the comment of the product
  #
  #
  # @params:
  #   post_type: string - "edit"
  #   status_id: StatusMessage.id of the user
  #   change_note: comment for StatusMessage.id
  #   product_id: the product user id
  #   group_comment_id: StatusMessage.id of the prodct
  #   comment_note: StatusMessage.text for the prodect
  #
  def udpate_status
    
  end
  
  #
  # POST: /user/matching
  # 
  # 1. 
  # 
  # @params:
  #   post_type: String - "new match"
  #   status_request_id: StatusMessage.id of the user
  #   status_request_note: StatusMessage.text of the user
  #   seller_id: Another profile id of a seller in Diaspora
  #   comment_request_note: StatusMessage.text of the seller on the user
  #   status_offer_id: StatusMessage.id of the seller
  #   status_request_note: StatusMessage.text of the seller
  #   comment_offer_note: StatusMessage.text of Bizmarket user
  #   bizmarket_user_id: The ID of Bizmarket user 
  #
  #
  # return :json => {
  #   :status => 200,
  #   --- the comment id of Bizmarket user.id
  # }
  #
  
  private
  def check_registrations_open!
    if AppConfig[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end
end
