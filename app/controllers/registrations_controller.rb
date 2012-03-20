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
  #   - change it to profile_email
  # @group_comment_id: StatusMessage.id of the product user.
  # @comment_note: StatusMessage.text of the product user.
  # 
  # @return {
  #   StatusMessage.last.id
  # }
  #
  def sign_in_by_email
    # Validate params
    validate_params = [
      :post_type,
      :status_note,
      :profile_email,
      :group_comment_id,
      :comment_note,
    ]
    validate_params.each do |param_name|
      if params[param_name].nil?
        return render :json => {:status => 403, :message => "No #{param_name} was provided."}
      end
    end
    # Find params
    
    # Search by email
    @user = User.where(:email => params[:profile_email]).first
    feedback_message = ""
    if @user.nil?
      feedback_message << "No user found by email: #{params[:profile_email]} \n"
      puts "No user found by email: #{params[:profile_email]}"
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
        feedback_message << "User successfuly saved. Email: #{user_email} \n"
      else
        feedback_message << "Error: User not saved. Email: #{user_email}"
        return render :json => {
          :status => 500,
          :message => feedback_message
        }
      end
    else
      feedback_message << "User found by email address: #{user_email} \n"
      puts "User found by email address: #{user_email}"
    end
    
    # Update status
    comment = Comment.find(params[:group_comment_id].to_i)
    if comment.nil?
      return render :json => {
        :status => 400,
        :message => feedback_message+" \n comment not found by #{params[:group_comment_id]}"
      }
    end
    comment.text = params[:comment_note]
    
    # Updsate the user status
    user_post = Post.new
    user_post.type = params[:post_type]
    user_post.text  params[:status_note]
      
    if ((!comment.save) || (!user_post.save))
      return render :json => {
        :status => 500,
        :message => feedback_message+" \n Error on saving. #{user_post.errors}; #{comment.errors}"
      }
    end
    
    return render :json => {
      :status => 200,
      :message => feedback_message
    }
  end
  
  #
  # POST: /users/update_message_status
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
  #     - commentable_id = Post.find(params[:status_id)
  #     - comment = Comment.where(:commentable_id => 
  #     
  #     - Post.comments.first {
  #          :commentable_id = Post.id
  #       }
  #
  def update_message_status
    # Validate params
    validate_params = [
      :post_type,
      :status_id,
      :change_note,
      :product_id,
      :group_comment_id,
      :comment_note,
    ]
    validate_params.each do |param_name|
      if params[param_name].nil?
        return render :json => {:status => 403, :message => "No #{param_name} was provided."}
      end
    end
    # Validate the status_id
#    user_status = StatusMessage.where(:id => params[:status_id]).first
    user_status = Post.where(:id => params[:status_id]).first
#    user_status = Comment.where(:commentable_id => params[:status_id]).first
    if user_status.nil?
      return render :json => {:status => 404, :message => "Post for status_id not found"}
    end
    # Validate product_id
    person = Person.where(:id => params[:product_id]).first
    if person.nil?
      return render :json => {:status => 404, :message => "Person (product_id) not found"}
    end
    # Validate group_comment_idco
#    comment = Comment.where(:id => params[:id]).first
    # To lower the number of DB queries
    comment = user_status.comments.find(params[:group_comment_id].to_i)
    if comment.nil?
      return render :json => {:status => 404, :message => "Post for group_comment_id not found"}
    end
    
    # Update the data with all of the params
    user_status.text = params[:change_note]
    comment.text = params[:comment_note]
    if ((!user_status.save) || (!comment.save))
      return render :json =>{:status => 500, :message => "There was a problem to save the data. "+user_status.errors.to_s+" ; "+comment.errors.to_s}
    end
    
    render :json => {
      :status => 200,
      :message => "Post and Comment were successfuly updated",
      :result => {
        :comment_id => comment.id
      }
    }
  end
  
  #
  # POST: /users/matching
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
  #   bizmarket_user_id: The ID of Bizmarket user 
  #   comment_offer_note: StatusMessage.text of Bizmarket user
  #
  #
  # return :json => {
  #   :status => 200,
  #   --- the comment id of Bizmarket user.id
  # }
  #
  def update_matching
    # Validate params
    validate_params = [
      :post_type,
      :status_request_id,
      :seller_id,
      :comment_request_note,
      :status_offer_id,
      :status_request_note,
      :comment_offer_note,
      :bizmarket_user_id,
    ]
    validate_params.each do |param_name|
      if params[param_name].nil?
        return render :json => {:status => 403, :message => "No #{param_name} was provided."}
      end
    end
    
    user_status_message=  Post.find(params[:status_request_id].to_i)
    if user_status_message.nil?
      return render :json => {:status => 404, :message => "user_status_message not found"}
    end
    seller = Profile.find(params[:seller_id].to_i)
    if seller.nil?
      return render :json => {:status => 404, :message => "seller_id not found"}
    end
    offer = Post.find(params[:status_offer_id].to_i)
    if offer.nil?
      return render :json => {:status => 404, :message => "status_offer_id not found"}
    end
    bizmarket_user = Person.find(params[:bizmarket_user_id])
    if bizmarket_user.nil?
      return render :json => {:status => 404, :message => "bizmarket_user_id not found"}
    end

    puts "-----------------"
    puts "status mesage:"
    user_status_message.text
    puts "seller"
    seller.full_name
    puts "offer"
    offer.text
    puts "bizmarket_user"
    bizmarket_user.full_name
    puts "-----------------"
    
    user_status_message.text  = params[:status_request_note]
    offer.text                = params[:comment_request_note]
    seller_status             = StatusMessage.new
    seller_status.text        = params[:status_request_note]
    seller_status.public      = true
    seller_status.author_id   = params[:seller_id]
    bizmarket_user.author_id  = params[:bizmarket_user_id]
    bizmarket_user.text       = params[:comment_offer_note]
    
    if ((!user_status_message.save) || (!seller_status.save) || (!offer.save) || (!bizmarket_user.save))
      return render :json => {:status => 500, :message => "Error on saving data."+user_status_message.errors.to_s+" "+offer.errors.to_s+" "+seller_status.errors.to_s+" "+bizmarket_user.errors.to_s}
    end
    
    render :json => {
      :status => 200,
      :message => "Data successfully updated"
    }
  end
  
  private
  def check_registrations_open!
    if AppConfig[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end
end
