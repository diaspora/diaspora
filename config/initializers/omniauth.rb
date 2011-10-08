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
  if SERVICES['twitter'] && SERVICES['twitter']['consumer_key'] && SERVICES['twitter']['consumer_secret']
    provider :twitter, SERVICES['twitter']['consumer_key'], SERVICES['twitter']['consumer_secret']
  end
  if SERVICES['tumblr'] && SERVICES['tumblr']['consumer_key'] && SERVICES['tumblr']['consumer_secret']
    provider :tumblr, SERVICES['tumblr']['consumer_key'], SERVICES['tumblr']['consumer_secret']
  end
  if SERVICES['facebook'] && SERVICES['facebook']['app_id'] && SERVICES['facebook']['app_secret']
    provider :facebook, SERVICES['facebook']['app_id'], SERVICES['facebook']['app_secret'],  { :scope => "publish_stream,email,offline_access",
                                                                                               :client_options => {:ssl => {:ca_file => AppConfig[:ca_file]}}}
  end
end
