#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  config.action_mailer.default_url_options = {:host => AppConfig[:pod_uri].host}
  unless Rails.env == 'test' || AppConfig[:mailer_on] != true
    config.action_mailer.delivery_method = :smtp
    if AppConfig[:smtp_authentication] == "none"
      config.action_mailer.smtp_settings = {
        :address => AppConfig[:smtp_address],
        :port => AppConfig[:smtp_port],
        :domain => AppConfig[:smtp_domain]
      }
    else
      config.action_mailer.smtp_settings = {
        :address => AppConfig[:smtp_address],
        :port => AppConfig[:smtp_port],
        :domain => AppConfig[:smtp_domain],
        :authentication => AppConfig[:smtp_authentication],
        :user_name => AppConfig[:smtp_username],
        :password => AppConfig[:smtp_password],
        :enable_starttls_auto => true
      }
    end
  end
end
