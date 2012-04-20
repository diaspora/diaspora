# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

Airbrake.configure do |config|
  if AppConfig[:airbrake_api_key].present?
    config.api_key = AppConfig[:airbrake_api_key] 
  else
    # creative way to disable Airbrake, should be replaced once the gem provides a proper way
    config.development_environments << Rails.env
  end
end
