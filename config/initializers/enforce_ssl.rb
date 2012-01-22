# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

if EnviromentConfiguration.enforce_ssl?
  Rails.application.config.middleware.insert_before ActionDispatch::Cookies, Rack::SSL
  puts "Rack::SSL is enabled"
end
