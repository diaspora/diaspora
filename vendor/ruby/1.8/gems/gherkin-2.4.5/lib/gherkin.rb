require 'gherkin/lexer/i18n_lexer'
require 'gherkin/parser/parser'
if defined?(JRUBY_VERSION)
  require 'json-simple-1.1.jar'
  require 'base64-2.3.8.jar'
end
