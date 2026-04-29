# frozen_string_literal: true

# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
# Hack to allow us to access app config, rather than putting this in environments/production.rb.

if Rails.env.production?
  Diaspora::Application.configure do
    if AppConfig.privacy.piwik.enable?
      require "rack/piwik"
      config.middleware.use Rack::Piwik, piwik_url: AppConfig.privacy.piwik.host.get,
                                         piwik_id:  AppConfig.privacy.piwik.site_id.get
    end
  end
end
