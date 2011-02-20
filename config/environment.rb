#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

if File.exists?(File.expand_path("./config/locale_settings.yml"))
  locale_settings = YAML::load(File.open(File.expand_path("./config/locale_settings.yml")))
  AVAILABLE_LANGUAGES = (locale_settings['available'].length > 0) ? locale_settings['available'] : { :en => 'English' }
  DEFAULT_LANGUAGE = (AVAILABLE_LANGUAGES.include?(locale_settings['default'])) ? locale_settings['default'] : AVAILABLE_LANGUAGES.keys[0].to_s
  AVAILABLE_LANGUAGE_CODES = locale_settings['available'].keys.map { |v| v.to_s }
  LANGUAGE_CODES_MAP = locale_settings['fallbacks']
else
  AVAILABLE_LANGUAGES = { :en => 'English' }
  DEFAULT_LANGUAGE = 'en'
  AVAILABLE_LANGUAGE_CODES = ['en']
  LANGUAGE_CODES_MAP = {}
end

# Initialize the rails application
Diaspora::Application.initialize!
