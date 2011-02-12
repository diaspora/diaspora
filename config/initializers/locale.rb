#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = DEFAULT_LANGUAGE
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
AVAILABLE_LANGUAGE_CODES.each do |c|
  if LANGUAGE_CODES_MAP.key?(c)
    I18n.fallbacks[c.to_sym] = LANGUAGE_CODES_MAP[c]
    I18n.fallbacks[c.to_sym].concat([c.to_sym, DEFAULT_LANGUAGE.to_sym, :en])
  else
    I18n.fallbacks[c.to_sym] = [c.to_sym, DEFAULT_LANGUAGE.to_sym, :en]
  end
end

# Workaround for https://rails.lighthouseapp.com/projects/8994/tickets/5329-using-i18nwith_locale-in-actionmailer-raises-systemstackerror
module AbstractController
  class I18nProxy
    def initialize(i18n_config, lookup_context)
      @i18n_config, @lookup_context = i18n_config, lookup_context
      @i18n_config = @i18n_config.i18n_config if @i18n_config.respond_to?(:i18n_config)
    end
  end
end
