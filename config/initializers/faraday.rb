#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Use net_http in test, that's better supported by webmock
unless Rails.env.test?
  require 'typhoeus/adapters/faraday'
  Faraday.default_adapter = :typhoeus
end

options = {
  request: {
    timeout: 25
  },
  ssl: {
    ca_file: AppConfig.environment.certificate_authorities.get
  }
}

Faraday.default_connection = Faraday::Connection.new(options) do |b|
  b.use FaradayMiddleware::FollowRedirects
  b.adapter Faraday.default_adapter
end
