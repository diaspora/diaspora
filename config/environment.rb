#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

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

if File.exists?(File.expand_path("./config/langcodes_alias_map.yml"))
  LANGUAGE_CODES_MAP = YAML::load(File.open(File.expand_path("./config/langcodes_alias_map.yml")))
else
  LANGUAGE_CODES_MAP = {}
end

# Initialize the rails application
Diaspora::Application.initialize!
