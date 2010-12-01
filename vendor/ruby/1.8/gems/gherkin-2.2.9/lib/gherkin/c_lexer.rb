require 'rbconfig'

module Gherkin
  module CLexer
    def self.[](i18n_underscored_iso_code)
      begin
        prefix = Config::CONFIG['arch'] =~ /mswin|mingw/ ? "#{Config::CONFIG['MAJOR']}.#{Config::CONFIG['MINOR']}/" : ''
        lib = "#{prefix}gherkin_lexer_#{i18n_underscored_iso_code}"
        require lib
        const_get(i18n_underscored_iso_code.capitalize)
      rescue LoadError => e
        e.message << %{\nCouldn't load #{lib}\nThe $LOAD_PATH was:\n#{$LOAD_PATH.join("\n")}}
        raise e
      end
    end
  end
end
