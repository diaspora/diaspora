#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = {:host => 'pivots.joindiaspora.com'}
  config.action_mailer.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'mail.joindiaspora.com',
    :authentication => 'plain',
    :user_name => 'diaspora-pivots@joindiaspora.com',
    :password => "xy289|]G+R*-kA",
    :enable_starttls_auto => true
  }
end
