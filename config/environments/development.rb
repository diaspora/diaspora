#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require File.expand_path('../../../lib/mongo_mapper/clear_dev_memory', __FILE__)
Diaspora::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :log
  config.middleware.use MongoMapper::ClearDevMemory
  #config.threadsafe!

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = {:host => 'pivots.joindiaspora.com'}
  config.action_mailer.smtp_settings = {
    :address => 'pivots.joindiaspora.com',
    :port => 587,
    :domain => 'mail.joindiaspora.com',
    :authentication => 'plain',
    :user_name => 'diaspora-pivots@joindiaspora.com',
    :password => "xy289|]G+R*-kA",
    :enable_starttls_auto => true
  }
end
