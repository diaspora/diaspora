module Cucumber
  # This module defines the API for programming language support in Cucumber.
  # While Cucumber itself is written in Ruby, any programming language can
  # be supported by implementing this API.
  #
  # For the sake of illustration we'll consider an imaginary language called
  # _why. _why files have the .why extension, so we need to put support for
  # this language in the <tt>Cucumber::WhySupport::WhyLanguage</tt>. This
  # class must be defined in a file called <tt>cucumber/why_support/why_language.rb</tt>
  # and be available on Ruby's <tt>$LOAD_PATH</tt>:
  #
  #   module Cucumber
  #     module WhySupport
  #       class WhyLanguage
  #
  #         # Uses whatever available language bridge to load
  #         # +why_file+ and returns an Array of StepDefinition.
  #         def load_code_file(why_file)
  #         end
  #       end
  #     end
  #   end
  #
  # Each language implementation manages its own hooks, and must execute them
  # at appropriate times.
  #   
  #
  module LanguageSupport
  end
end
