require 'cucumber/formatter/usage'

module Cucumber
  module Formatter
    class Stepdefs < Usage
      def print_steps(stepdef_key)
      end

      def max_step_length
        0
      end
    end
  end
end