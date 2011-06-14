class AuthorizationsController < ApplicationController
  include OAuth2::Provider::Rack::AuthorizationCodesSupport
  before_filter :authenticate_user!, :except => :token
  before_filter :block_invalid_authorization_code_requests, :except => [:token, :index, :destroy]

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
      manifest = JSON.parse(RestClient.get(params[:manifest_url]).body)

      message = verify(params[:signed_string], params[:signature], manifest['public_key'])
      unless message =='ok' 
        render :text => message, :status => 403
      else
        client = OAuth2::Provider.client_class.create_from_manifest!(manifest)

        render :json => {:client_id => client.oauth_identifier,
                         :client_secret => client.oauth_secret,
                         :expires_in => 0,
                         :flows_supported => "",
                        }

      end
    else
      render :text => "bad request", :status => 403
    end
  end

  def index
    @authorizations = current_user.authorizations
    @applications = current_user.applications
  end

  def destroy
    ## ID is actually the id of the client
    auth = current_user.authorizations.where(:client_id => params[:id]).first
    auth.revoke
    redirect_to authorizations_path
  end


  def verify_signature(challenge, signature, serialized_pub_key)
    public_key = OpenSSL::PKey::RSA.new(serialized_pub_key) 
    public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), challenge)
  end

  def valid_time?(time)
    time.to_i > (Time.now - 5.minutes).to_i
  end

  def valid_nonce?(nonce)
    OAuth2::Provider.client_class.where(:nonce => nonce).first.nil?
  end
end

OAuth2::Provider.client_class.instance_eval do
  def self.create_from_manifest! manifest
    create!(manifest)
  end
end
