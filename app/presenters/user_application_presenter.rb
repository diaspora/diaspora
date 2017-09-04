# frozen_string_literal: true

class UserApplicationPresenter
  attr_reader :scopes

  def initialize(application, scopes, authorization_id=nil)
    @app = application
    @scopes = scopes
    @authorization_id = authorization_id
  end

  def id
    @authorization_id
  end

  def name
    @app.client_name
  end

  def image
    @app.image_uri
  end

  def terms_of_services
    @app.tos_uri
  end

  def policy
    @app.policy_uri
  end

  def name?
    @app.client_name.present?
  end

  def terms_of_services?
    @app.tos_uri.present?
  end

  def policy?
    @app.policy_uri.present?
  end

  def url
    client_redirect = URI(@app.redirect_uris[0])
    client_redirect.path = "/"
    client_redirect.to_s
  end
end
