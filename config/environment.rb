#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

if File.exists?(File.expand_path("./config/fb_config.yml"))
  # Load facebook connection application credentials
  fb_config  = YAML::load(File.open(File.expand_path("./config/fb_config.yml")))
  FB_API_KEY = fb_config['fb_api_key']
  FB_SECRET  = fb_config['fb_secret']
  FB_APP_ID  = fb_config['fb_app_id']
  HOST       = fb_config['host']
  FACEBOOK   = true
else
  FACEBOOK   = false
end

if File.exists?(File.expand_path("./config/languages.yml"))
  languages = YAML::load(File.open(File.expand_path("./config/languages.yml")))
  AVAILABLE_LANGUAGES = (languages['available'].length > 0) ? languages['available'] : { :en => 'English' }
  DEFAULT_LANGUAGE = (AVAILABLE_LANGUAGES.include?(languages['default'])) ? languages['default'] : AVAILABLE_LANGUAGES.keys[0].to_s
  AVAILABLE_LANGUAGE_CODES = languages['available'].keys.map { |v| v.to_s }
else
  AVAILABLE_LANGUAGES = { :en => 'English' }
  DEFAULT_LANGUAGES = 'en'
  AVAILABLE_LANGUAGE_CODES = ['en']
end

# Initialize the rails application
Diaspora::Application.initialize!

