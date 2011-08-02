module RSpec
  module Matchers
    # :call-seq:
    #   should match(pattern)
    #   should_not match(pattern)
    #
    # Given a Regexp or String, passes if actual.match(pattern)
    #
    # == Examples
    #
    #   email.should match(/^([^\s]+)((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    #   email.should match("@example.com")
    def match(expected)
      Matcher.new :match, expected do |_expected_|
        match do |actual|
          actual.match(_expected_)
        end
      end
    end
  end
end
