Rails.application.config.middleware.insert 0, Rack::Cors do
  allow do
    origins "*"
    resource "/.well-known/host-meta"
    resource "/webfinger"
    resource "/.well-known/webfinger"
    resource "/.well-known/openid-configuration"
    resource "/api/openid_connect/user_info", methods: :get
    resource "/api/v0/*", methods: %i(get post delete)
  end
end
