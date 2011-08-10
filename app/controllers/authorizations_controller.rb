require File.join(Rails.root, "app", "models", "oauth2_provider_models_activerecord_authorization")
require File.join(Rails.root, "app", "models", "oauth2_provider_models_activerecord_client")

class AuthorizationsController < ApplicationController
  include OAuth2::Provider::Rack::AuthorizationCodesSupport
  before_filter :authenticate_user!, :except => :token
  before_filter :block_invalid_authorization_code_requests, :except => [:token, :index, :destroy]

  skip_before_filter :verify_authenticity_token, :only => :token

  def new
    @requested_scopes = params["scope"].split(',')
    @client = oauth2_authorization_request.client

    if authorization = current_user.authorizations.where(:client_id => @client.id).first
      ac = authorization.authorization_codes.create(:redirect_uri => params[:redirect_uri])
      #tokens = current_user.authorizations.first.access_tokens.first
      redirect_to "#{params[:redirect_uri]}&code=#{ac.code}"
    end
  end

  def create
    if params[:commit] == "Authorize"
      grant_authorization_code(current_user)
    else
      deny_authorization_code
    end
  end

  def token
    require 'jwt'

    signed_string = Base64.decode64(params[:signed_string])
    app_url = signed_string.split(';')[0]

    if (!params[:type] == 'client_associate' && !app_url)
      render :text => "bad request: #{params.inspect}", :status => 403
      return
    end
      packaged_manifest = JSON.parse(RestClient.get("#{app_url}manifest.json").body)
      public_key = OpenSSL::PKey::RSA.new(packaged_manifest['public_key'])
      manifest = JWT.decode(packaged_manifest['jwt'], public_key)

      message = verify(signed_string, Base64.decode64(params[:signature]), public_key, manifest)
      if not (message =='ok')
        render :text => message, :status => 403
      elsif manifest["application_base_url"].match(/^https?:\/\/(localhost|chubbi\.es|www\.cubbi\.es|cubbi\.es)(:\d+)?\/$/).nil?
        # This will only be temporary (less than a month) while we iron out the kinks in Diaspora Connect. Essentially,
        # whatever we release people will try to work off of and it sucks to build things on top of non-stable things.
        # We also started writing a gem that we'll release (around the same time) that makes becoming a Diaspora enabled
        # ruby project a breeze.

        render :text => "Domain (#{manifest["application_base_url"]}) currently not authorized for Diaspora OAuth", :status => 403
      else
        client = OAuth2::Provider.client_class.create_or_reset_from_manifest!(manifest, public_key)

        render :json => {:client_id => client.oauth_identifier,
                         :client_secret => client.oauth_secret,
                         :expires_in => 0,
                         :flows_supported => ""}
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

  # @param [String] enc_signed_string A Base64 encoded string with app_url;pod_url;time;nonce
  # @param [String] sig A Base64 encoded signature of the decoded signed_string with public_key.
  # @param [OpenSSL::PKey::RSA] public_key The application's public key to verify sig with.
  # @return [String] 'ok' or an error message.
  def verify( signed_string, sig, public_key, manifest)
    split = signed_string.split(';')
    app_url = split[0]
    time = split[2]
    nonce = split[3]

    return 'blank public key' if public_key.n.nil?
    return "the app url in the manifest (#{manifest['application_base_url']}) does not match the url passed in the parameters (#{app_url})." if manifest["application_base_url"] != app_url
    return 'key too small, use at least 2048 bits' if public_key.n.num_bits < 2048
    return "invalid time" unless valid_time?(time)
    return 'invalid nonce' unless valid_nonce?(nonce)
    return 'invalid signature' unless verify_signature(signed_string, sig, public_key)
    'ok'
  end

  def verify_signature(challenge, signature, public_key)
    public_key.verify(OpenSSL::Digest::SHA256.new, signature, challenge)
  end

  def valid_time?(time)
    time.to_i > (Time.now - 5.minutes).to_i
  end

  def valid_nonce?(nonce)
    !OAuth2::Provider.client_class.exists?(:nonce => nonce)
  end
end
