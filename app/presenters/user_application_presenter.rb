class UserApplicationPresenter
  def initialize(application, scopes, authorization_id=nil)
    @app = application
    @scopes = scopes
    @authorization_id = authorization_id
  end

  def scopes
    @scopes
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

  def name?
    if @app.client_name
      true
    else
      false
    end
  end

  def url
    client_redirect = URI(@app.redirect_uris[0])
    "#{client_redirect.scheme}://#{client_redirect.host}"
  end
end
