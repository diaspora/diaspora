#encoding: utf-8
if !defined?(JRUBY_VERSION) && !(defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby") && ENV['GHERKIN_JS'] && !ENV['SKIP_JS_SPECS']
require 'spec_helper'
require 'gherkin/js_lexer'

module Gherkin
  module Lexer
    describe "Javascript Lexer" do
      before do
        @listener = Gherkin::SexpRecorder.new
        @lexer = Gherkin::JsLexer['en'].new(@listener)
      end
    
      it_should_behave_like "a Gherkin lexer"
      it_should_behave_like "a Gherkin lexer lexing tags"
      it_should_behave_like "a Gherkin lexer lexing doc_strings"
      it_should_behave_like "a Gherkin lexer lexing rows"
      # TODO - make this pass!
      # it_should_behave_like "parsing windows files"
    end
  end
end
end
