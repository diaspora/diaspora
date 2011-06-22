#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Faraday.default_connection = Faraday::Connection.new( :ssl => {:ca_file => AppConfig[:ca_file]}, :timeout => 5 ) do |b|
  b.use FaradayStack::FollowRedirects
  b.adapter Faraday.default_adapter
end
