# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'i18n_interpolation_fallbacks'
require "i18n/backend/fallbacks"

settings_file = Pathname.new(__FILE__).dirname.join('..').expand_path.join('locale_settings.yml')
if settings_file.exist?
  locale_settings = YAML.load_file(settings_file)
  AVAILABLE_LANGUAGES = (locale_settings['available'].length > 0) ? locale_settings['available'] : { "en" => 'English' }
  AVAILABLE_LANGUAGE_CODES = locale_settings['available'].keys
  LANGUAGE_CODES_MAP = locale_settings['fallbacks']
  RTL_LANGUAGES = locale_settings['rtl']
else
  AVAILABLE_LANGUAGES = { "en" => 'English' }
  AVAILABLE_LANGUAGE_CODES = ["en"]
  LANGUAGE_CODES_MAP = {}
  RTL_LANGUAGES = []
end

DEFAULT_LANGUAGE = "en"


# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
# Use the railtie configuration option to ensure overiding devise.
Diaspora::Application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = DEFAULT_LANGUAGE

I18n::Backend::Simple.send(:include, I18n::Backend::InterpolationFallbacks)
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

AVAILABLE_LANGUAGE_CODES.each do |c|
  I18n.fallbacks[c] = [c]
  if LANGUAGE_CODES_MAP.key?(c)
    I18n.fallbacks[c].concat(LANGUAGE_CODES_MAP[c])
  end
  I18n.fallbacks[c].concat([DEFAULT_LANGUAGE, "en"])
end
