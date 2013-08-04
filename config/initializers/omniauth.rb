#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Rails.application.config.middleware.use OmniAuth::Builder do
  if AppConfig.services.twitter.enable?
    provider :twitter, AppConfig.services.twitter.key, AppConfig.services.twitter.secret
    Twitter.configure do |config|
      config.consumer_key = AppConfig.services.twitter.key
      config.consumer_secret = AppConfig.services.twitter.secret
    end
  end
  
  if AppConfig.services.tumblr.enable?
    provider :tumblr, AppConfig.services.tumblr.key, AppConfig.services.tumblr.secret
  end
  
  if AppConfig.services.facebook.enable?
    provider :facebook, AppConfig.services.facebook.app_id, AppConfig.services.facebook.secret, {
      display: 'popup',
      scope: 'publish_actions,publish_stream,offline_access',
      client_options: {
        ssl: {
          ca_file: AppConfig.environment.certificate_authorities
        }
      }
    }  
  end
  
  if AppConfig.services.wordpress.enable?
    provider :wordpress, AppConfig.services.wordpress.client_id, AppConfig.services.wordpress.secret
  end
end
