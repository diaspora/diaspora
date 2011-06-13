class AuthorizationsController < ApplicationController
  include OAuth2::Provider::Rack::AuthorizationCodesSupport
  before_filter :authenticate_user!, :except => :token
  before_filter :block_invalid_authorization_code_requests, :except => [:token, :index]

  skip_before_filter :verify_authenticity_token, :only => :token

  def new
    @requested_scopes = params["scope"].split(',')
    @client = oauth2_authorization_request.client
    render :layout => "popup" if params[:popup]
  end

  def create
    if params[:commit] == "Authorize"
      grant_authorization_code(current_user)
    else
      deny_authorization_code
    end
  end

  def token
    if(params[:type] == 'client_associate' && params[:manifest_url])
      client = OAuth2::Provider.client_class.create_from_manifest!(params[:manifest_url])

      render :json => {:client_id => client.oauth_identifier,
                       :client_secret => client.oauth_secret,
                       :expires_in => 0,
                       :flows_supported => "",
                      }

    else
      render :text => "bad request", :status => 403
    end
  end

  def index
    @authorizations = current_user.authorizations
    @applications = current_user.applications
  end
end

OAuth2::Provider.client_class.instance_eval do
  def self.create_from_manifest! manifest_url
    manifest = JSON.parse(RestClient.get(manifest_url).body)
    create!(manifest)
  end
end
