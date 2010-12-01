module RSpec
  module Matchers
    # :call-seq:
    #   should eql(expected)
    #   should_not eql(expected)
    #
    # Passes if actual and expected are of equal value, but not necessarily the same object.
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # == Examples
    #
    #   5.should eql(5)
    #   5.should_not eql(3)
    def eql(expected)
      Matcher.new :eql, expected do |_expected_|

        diffable

        match do |actual|
          actual.eql?(_expected_)
        end

        failure_message_for_should do |actual|
          <<-MESSAGE

expected #{_expected_.inspect}
     got #{actual.inspect}

(compared using eql?)
MESSAGE
        end

        failure_message_for_should_not do |actual|
          <<-MESSAGE

expected #{actual.inspect} not to equal #{_expected_.inspect}

(compared using eql?)
MESSAGE
        end
      end
    end
  end
end
