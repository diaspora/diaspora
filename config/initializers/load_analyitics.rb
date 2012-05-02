# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
#hack to allow us to access app config, rather than putting in enviroments/production.rb

if Rails.env == 'production'
  Diaspora::Application.configure do
    if AppConfig[:piwik_url].present?
      config.gem 'rack-piwik', :lib => 'rack/piwik'
      config.middleware.use Rack::Piwik, :piwik_url => AppConfig[:piwik_url], :piwik_id => AppConfig[:piwik_id]
    end
  end
end
