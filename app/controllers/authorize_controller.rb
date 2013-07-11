class AuthorizeController < ApplicationController
  
  before_filter :authenticate_user!
  ALL_SCOPES = %w(profile_read 
                  contact_list_read 
                  post_write 
                  post_read 
                  post_delete 
                  comment_read 
                  comment_write)

  def show
    auth_token = params[:auth_token]
    @diaspora_handle = params[:diaspora_handle]

    #TODO check user mismatch
    #if not  <app user>== current_user.diaspora_handle
    #  render :status => :bad_request, :json => {:error => "102"} #usermismatch
    #end

    @access_request = Dauth::AccessRequest.find_by_auth_token(auth_token)

    if @access_request
      @dev = Webfinger.new(@access_request.dev_handle).fetch   #developer profile details
      @scopes = ALL_SCOPES - @access_request.scopes
    else
      Rails.logger.info("Authentication token #{@auth_token} is illegal")
      render :status => :bad_request, :json => {:error => "100"} #illegal authentication token 
    end
  end
  
end
