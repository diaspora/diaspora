require 'v8'

module Gherkin
  # Thin adapter for the Javascript lexer, primarily used for testing.
  class JsLexer
    def self.[](i18n_underscored_iso_code)
      cxt = V8::Context.new
      cxt['exports'] = {}

      # Mimic Node.js / Firebug console.log
      cxt['console'] = STDOUT
      def STDOUT.log(*a)
        p a
      end

      cxt.load(File.dirname(__FILE__) + "/../../js/lib/gherkin/lexer/#{i18n_underscored_iso_code}.js")
      cxt['exports']['Lexer']
    end
  end
end