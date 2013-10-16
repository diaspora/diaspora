class AuthorizeController < ApplicationController
  include Authenticator
  before_filter :authenticate_user!, :except => :verify
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

  def verify
    signed_manifest= params[:signed_manifest]

    if not signed_manifest
      render :status => :bad_request, :json => {:error => "000"}
      return
    end

    manifest = Manifest.by_signed_jwt signed_manifest

    if not manifest
      render :status => :bad_request, :json => {:error => "001"}
      return
    end

    res = manifest.verify signed_manifest

    if res
      access_req = Dauth::AccessRequest.new
      access_req.dev_handle = manifest.devloper_handle_from_jwt signed_manifest
      access_req.callback_url = manifest.callback_url
      access_req.scopes = manifest.scopes
      access_req.app_id = manifest.app_id
      access_req.app_name = manifest.app_name
      access_req.app_description = manifest.app_description
      access_req.app_version = manifest.app_version
      access_req.redirect_url = manifest.redirect_url
      access_req.save
      render :status => :ok, :json => {:auth_token => "#{access_req.auth_token}"}
    else
      render :status => :bad_request, :json => {:error => "002"}
    end
  end

  def update
    if params[:commit] == 'Deny'
      redirect_to stream_path
      return
    end

    access_request = Dauth::AccessRequest.find_by_auth_token(params[:authorize_token])
    current_user = Person.find_by_diaspora_handle(params[:handle]).owner
    refresh_token = current_user.refresh_tokens.find_or_create_by_app_id(access_request.app_id)

    if params[:scopes]
      refresh_token.scopes = access_request.scopes + params[:scopes]
    else
      refresh_token.scopes = access_request.scopes
    end

    if refresh_token.save
      #TODO save third-party application details
    else
      Rails.logger.info("Unable to generate refresh token")
      redirect_to access_request.redirect_url
      send_error_to_app access_request.callback_url, "101"
      return
    end
    redirect_to access_request.redirect_url
    send_refresh_token_to_app refresh_token.token, access_request.callback_url, current_user.diaspora_handle
  end
end
