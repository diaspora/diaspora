#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  config.serve_static_assets = AppConfig[:serve_static_assets] unless AppConfig[:serve_static_assets].nil?
  # config.static_cache_control = "public, max-age=3600" if AppConfig[:serve_static_assets].to_s == 'true'
end
