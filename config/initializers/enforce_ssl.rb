# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

unless AppConfig.environment.disable_ssl_requirement?
  Rails.application.config.middleware.insert_before 0, Rack::SSL
  puts "Rack::SSL is enabled"
end
