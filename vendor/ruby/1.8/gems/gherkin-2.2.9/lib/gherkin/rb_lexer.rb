module Gherkin
  module RbLexer
    def self.[](i18n_underscored_iso_code)
      require "gherkin/rb_lexer/#{i18n_underscored_iso_code}"
      const_get(i18n_underscored_iso_code.capitalize)
    end
  end
end