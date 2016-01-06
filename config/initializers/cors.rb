Rails.application.config.middleware.insert 0, Rack::Cors do
  allow do
    origins "*"
    resource "/api/openid_connect/user_info", methods: %i(get post)
    resource "/api/v0/*", methods: %i(delete get post)
    resource "/.well-known/host-meta"
    resource "/.well-known/webfinger"
    resource "/.well-known/openid-configuration"
    resource "/webfinger"
  end
end
