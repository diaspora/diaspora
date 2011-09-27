#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'i18n_interpolation_fallbacks'

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = DEFAULT_LANGUAGE

I18n::Backend::Simple.send(:include, I18n::Backend::InterpolationFallbacks)

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
AVAILABLE_LANGUAGE_CODES.each do |c|
  if LANGUAGE_CODES_MAP.key?(c)
    I18n.fallbacks[c.to_sym] = LANGUAGE_CODES_MAP[c]
    I18n.fallbacks[c.to_sym].concat([c.to_sym, DEFAULT_LANGUAGE.to_sym, :en])
  else
    I18n.fallbacks[c.to_sym] = [c.to_sym, DEFAULT_LANGUAGE.to_sym, :en]
  end
end

# There's almost certainly a better way to do this.
# Maybe by loading our paths in the initializer hooks, they'll end up after the gem paths?
class I18n::Railtie
  class << self
    def initialize_i18n_with_path_cleanup *args
      initialize_i18n_without_path_cleanup *args
      I18n.load_path.reject!{|path| path.match(/devise_invitable/) }
    end
    alias_method_chain :initialize_i18n, :path_cleanup
  end
end
