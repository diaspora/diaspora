#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = {:host => APP_CONFIG[:terse_pod_url]}
  config.action_mailer.smtp_settings = {
    :address => APP_CONFIG[:smtp_address],
    :port => APP_CONFIG[:smtp_port],
    :domain => APP_CONFIG[:smtp_domain],
    :authentication => APP_CONFIG[:smtp_authentication],
    :user_name => APP_CONFIG[:smtp_username],
    :password => APP_CONFIG[:smtp_password],
    :enable_starttls_auto => true
  }
end
