#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
options = {:timeout => 25}

options[:ssl] = {:ca_file => AppConfig.environment.certificate_authorities}
Faraday.default_connection = Faraday::Connection.new(options) do |b|
  b.use FaradayMiddleware::FollowRedirects
  b.adapter Faraday.default_adapter
end
