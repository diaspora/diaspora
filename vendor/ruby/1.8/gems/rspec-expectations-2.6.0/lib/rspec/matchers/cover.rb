module RSpec
  module Matchers
    # :call-seq:
    #   should cover(expected)
    #   should_not cover(expected)
    #
    # Passes if actual covers expected. This works for
    # Ranges. You can also pass in multiple args
    # and it will only pass if all args are found in Range.
    #
    # == Examples
    #   (1..10).should cover(5)
    #   (1..10).should cover(4, 6)
    #   (1..10).should cover(4, 6, 11) # will fail
    #   (1..10).should_not cover(11)
    #   (1..10).should_not cover(5)    # will fail
    #
    # == Warning: Ruby >= 1.9 only
    def cover(*values)
      Matcher.new :cover, *values do |*_values|
        match_for_should do |range|
          _values.all? &covered_by(range)
        end

        match_for_should_not do |range|
          _values.none? &covered_by(range)
        end

        def covered_by(range)
          lambda {|value| range.cover?(value)}
        end
      end
    end
  end
end
