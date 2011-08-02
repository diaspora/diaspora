module RSpec
  module Matchers
    # :call-seq:
    #   should eq(expected)
    #   should_not eq(expected)
    #
    # Passes if actual == expected.
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # == Examples
    #
    #   5.should eq(5)
    #   5.should_not eq(3)
    def eq(expected)
      Matcher.new :eq, expected do |_expected_|

        diffable

        match do |actual|
          actual == _expected_
        end

        failure_message_for_should do |actual|
          <<-MESSAGE

expected #{_expected_.inspect}
     got #{actual.inspect}

(compared using ==)
MESSAGE
        end

        failure_message_for_should_not do |actual|
          <<-MESSAGE

expected #{actual.inspect} not to equal #{_expected_.inspect}

(compared using ==)
MESSAGE
        end

        description do
          "== #{_expected_}"
        end
      end
    end
  end
end

