#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require_dependency "rack/fixed_request"
OmniAuth.config.full_host = lambda do |env|
  request_url = Rack::FixedRequest.new(env).url
  # Copied from OmniAuth::Strategy#full_host (omniauth-0.2.6)
  uri = URI.parse(request_url.gsub(/\?.*$/,''))
  uri.path = ''
  uri.query = nil
  uri.to_s
end

Rails.application.config.middleware.use OmniAuth::Builder do
  if AppConfig.services.twitter.enable?
    provider :twitter, AppConfig.services.twitter.key, AppConfig.services.twitter.secret
  end

  if AppConfig.services.tumblr.enable?
    provider :tumblr, AppConfig.services.tumblr.key, AppConfig.services.tumblr.secret
  end

  if AppConfig.services.facebook.enable?
    provider :facebook, AppConfig.services.facebook.app_id, AppConfig.services.facebook.secret, {
      scope:          "public_profile,publish_actions",
      client_options: {
        ssl: {
          ca_file: AppConfig.environment.certificate_authorities
        }
      }
    }
  end

  if AppConfig.services.wordpress.enable?
    provider :wordpress, AppConfig.services.wordpress.client_id, AppConfig.services.wordpress.secret
  end
end
