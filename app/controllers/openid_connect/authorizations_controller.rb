class OpenidConnect::AuthorizationsController < ApplicationController
  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    logger.info e.backtrace[0,10].join("\n")
    render json: { error: e.message || :error, status: e.status }
  end

  before_action :authenticate_user!

  def new
    request_authorization_consent_form
  end

  def create
    process_authorization_consent(params[:approve])
  end

  private

  def request_authorization_consent_form
    endpoint = OpenidConnect::Authorization::EndpointStartPoint.new(current_user)
    handle_startpoint_response(endpoint)
  end

  def handle_startpoint_response(endpoint)
    _status, header, response = *endpoint.call(request.env)
    if response.redirect?
      redirect_to header["Location"]
    else
      saveParamsAndRenderConsentForm(endpoint)
    end
  end

  def process_authorization_consent(approvedString)
    endpoint = OpenidConnect::Authorization::EndpointConfirmationPoint.new(current_user, to_boolean(approvedString))
    handle_confirmation_endpoint_response(endpoint)
  end

  def saveParamsAndRenderConsentForm(endpoint)
    @o_auth_application, @response_type, @redirect_uri, @scopes, @request_object = *[
      endpoint.o_auth_application, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes, endpoint.request_object
    ]
    save_request_parameters
    render :new
  end

  def handle_confirmation_endpoint_response(endpoint)
    restore_request_parameters(endpoint)
    _status, header, _response = *endpoint.call(request.env)
    delete_authorization_session_variables
    redirect_to header["Location"]
  end

  def restore_request_parameters(endpoint)
    req = Rack::Request.new(request.env)
    req.update_param("client_id", session[:client_id])
    req.update_param("redirect_uri", session[:redirect_uri])
    req.update_param("response_type", session[:response_type])
    endpoint.scopes, endpoint.request_object, endpoint.nonce =
      session[:scopes].map {|scope| Scope.find_by_name(scope) }, session[:request_object], session[:nonce]
  end

  def delete_authorization_session_variables
    session.delete(:client_id)
    session.delete(:response_type)
    session.delete(:redirect_uri)
    session.delete(:scopes)
    session.delete(:request_object)
    session.delete(:nonce)
  end

  def save_request_parameters
    session[:client_id], session[:response_type], session[:redirect_uri], session[:scopes], session[:request_object], session[:nonce] =
      @o_auth_application.client_id, @response_type, @redirect_uri, @scopes.map(&:name), @request_object, params[:nonce]
  end

  def to_boolean(str)
    str.downcase == "true"
  end
end
