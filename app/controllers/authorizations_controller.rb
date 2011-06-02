class AuthorizationsController < ApplicationController
  include OAuth2::Provider::Rack::AuthorizationCodesSupport
  before_filter :authenticate_user!, :except => :token
  before_filter :block_invalid_authorization_code_requests, :except => :token

  skip_before_filter :verify_authenticity_token, :only => :token

  def new
    @client = oauth2_authorization_request.client
  end

  def create
    if params[:commit] == "Yes"
      grant_authorization_code(current_user)
    else
      deny_authorization_code
    end
  end

  def token
    if(params[:type] == 'client_associate' && params[:redirect_uri] && params[:name])
      client = OAuth2::Provider.client_class.create!(:name => params[:name])

      render :json => {:client_id => client.oauth_identifier,
                      :client_secret => client.oauth_secret,
                      :expires_in => 0,
                      :flows_supported => "",
                      :user_endpoint_url => "bob"}

      #redirect_to("#{params[:redirect_uri]}?#{query_string}")

    else
      render :text => "bad request", :status => 403
    end
  end
end

