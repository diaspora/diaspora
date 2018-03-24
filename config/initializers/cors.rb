# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "/api/openid_connect/user_info", methods: %i(get post)
    resource "/api/v0/*", methods: %i(delete get post)
    resource "/.well-known/host-meta"
    resource "/.well-known/webfinger"
    resource "/.well-known/openid-configuration"
  end
end
