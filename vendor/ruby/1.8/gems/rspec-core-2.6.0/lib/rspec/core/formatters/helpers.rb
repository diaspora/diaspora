module RSpec
  module Core
    module Formatters

      module Helpers
        SUB_SECOND_PRECISION = 5
        DEFAULT_PRECISION = 2

        def format_seconds(float)
          precision ||= (float < 1) ? SUB_SECOND_PRECISION : DEFAULT_PRECISION
          formatted = sprintf("%.#{precision}f", float)
          strip_trailing_zeroes(formatted)
        end

        def strip_trailing_zeroes(string)
          stripped = string.sub(/[^1-9]+$/, '')
          stripped.empty? ? "0" : stripped
        end

      end

    end
  end
end
