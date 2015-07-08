class OpenidConnect::ClientsController < ApplicationController

  rescue_from OpenIDConnect::HttpError do |e|
    rewriteHTTPErrorPageAsJSON(e)
  end
  rescue_from OpenIDConnect::ValidationFailed do |e|
    rewriteValidationFailErrorPageAsJSON(e)
  end

  def create
    registrar = OpenIDConnect::Client::Registrar.new(request.url, params)
    client = OAuthApplication.register! registrar
    render json: client
  end

private

  def rewriteHTTPErrorPageAsJSON(e)
    render json: {
             error: :invalid_request,
             error_description: e.message
           }, status: 400
  end
  def rewriteValidationFailErrorPageAsJSON(e)
    render json: {
             error: :invalid_client_metadata,
             error_description: e.message
           }, status: 400
  end
end
