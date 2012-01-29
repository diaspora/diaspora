# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

if AppConfig[:airbrake_api_key].present?
  require 'airbrake'
  Airbrake.configure do |config|
    config.api_key = AppConfig[:airbrake_api_key]
  end
end