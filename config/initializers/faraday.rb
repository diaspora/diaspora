#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
options = {:timeout => 5}

options[:ssl] = {:ca_file => EnviromentConfiguration.ca_cert_file_location}
Faraday.default_connection = Faraday::Connection.new(options) do |b|
  b.use FaradayStack::FollowRedirects
  b.adapter Faraday.default_adapter
end
