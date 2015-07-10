class OpenidConnect::AuthorizationsController < ApplicationController
  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    logger.info e.backtrace[0,10].join("\n")
    render json: {error: e.message || :error, status: e.status}
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
    handleStartPointResponse(endpoint)
  end

  def handleStartPointResponse(endpoint)
    status, header, response = *endpoint.call(request.env)
    if response.redirect?
      redirect_to header['Location']
    else
      @client, @response_type, @redirect_uri, @scopes, @request_object = *[
        endpoint.client, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes, endpoint.request_object
      ]
      saveRequestParameters
      render :new
    end
  end

  def process_authorization_consent(approvedString)
    endpoint = OpenidConnect::Authorization::EndpointConfirmationPoint.new(current_user, to_boolean(approvedString))
    restoreRequestParameters(endpoint)
    handleConfirmationPointResponse(endpoint)
  end

  def handleConfirmationPointResponse(endpoint)
    status, header, response = *endpoint.call(request.env)
    redirect_to header['Location']
  end


  def saveRequestParameters
    session[:client_id], session[:response_type], session[:redirect_uri], session[:scopes], session[:request_object] =
      @client.client_id, @response_type, @redirect_uri, @scopes.collect { |scope| scope.name }, @request_object
  end

  def restoreRequestParameters(endpoint)
    req = Rack::Request.new(request.env)
    req.update_param("client_id", session[:client_id])
    req.update_param("redirect_uri", session[:redirect_uri])
    req.update_param("response_type", session[:response_type])
    endpoint.scopes, endpoint.request_object =
      session[:scopes].collect {|scope| Scope.find_by_name(scope)}, session[:request_object]
  end

  def to_boolean(str)
    str.downcase == "true"
  end
end
