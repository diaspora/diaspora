class AuthorizationsController < ApplicationController
  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    logger.info e.backtrace[0,10].join("\n")
    render :error, status: e.status
  end

  def new
    call_authorization_endpoint
  end

  def create
    call_authorization_endpoint :allow_approval, params[:approve]
  end

  private

  def call_authorization_endpoint(allow_approval = false, approved = false)
    endpoint = AuthorizationEndpoint.new allow_approval, approved
    rack_response = *endpoint.call(request.env)
    @client, @response_type, @redirect_uri, @scopes, @_request_, @request_uri, @request_object = *[
        endpoint.client, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes, endpoint._request_, endpoint.request_uri, endpoint.request_object
    ]
    require_authentication
    if (
    !allow_approval &&
        (max_age = @request_object.try(:id_token).try(:max_age)) &&
        current_account.last_logged_in_at < max_age.seconds.ago
    )
      flash[:notice] = 'Exceeded Max Age, Login Again'
      unauthenticate!
      require_authentication
    end
    respond_as_rack_app *rack_response
  end

  def respond_as_rack_app(status, header, response)
    ["WWW-Authenticate"].each do |key|
      headers[key] = header[key] if header[key].present?
    end
    if response.redirect?
      redirect_to header['Location']
    else
      render :new
    end
  end
end
