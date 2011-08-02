module RSpec
  module Matchers
    # :call-seq:
    #   should include(expected)
    #   should_not include(expected)
    #
    # Passes if actual includes expected. This works for
    # collections and Strings. You can also pass in multiple args
    # and it will only pass if all args are found in collection.
    #
    # == Examples
    #
    #   [1,2,3].should include(3)
    #   [1,2,3].should include(2,3) #would pass
    #   [1,2,3].should include(2,3,4) #would fail
    #   [1,2,3].should_not include(4)
    #   "spread".should include("read")
    #   "spread".should_not include("red")
    def include(*expected)
      Matcher.new :include, *expected do |*_expected|

        diffable

        match_for_should do |actual|
          perform_match(:all?, :all?, actual, _expected)
        end

        match_for_should_not do |actual|
          perform_match(:none?, :any?, actual, _expected)
        end

        def perform_match(predicate, hash_predicate, actual, _expected)
          _expected.send(predicate) do |expected|
            if comparing_hash_values?(actual, expected)
              expected.send(hash_predicate) {|k,v| actual[k] == v}
            elsif comparing_hash_keys?(actual, expected)
              actual.has_key?(expected)
            else
              actual.include?(expected)
            end
          end
        end

        def comparing_hash_keys?(actual, expected) # :nodoc:
          actual.is_a?(Hash) && !expected.is_a?(Hash)
        end

        def comparing_hash_values?(actual, expected) # :nodoc:
          actual.is_a?(Hash) && expected.is_a?(Hash)
        end
      end
    end
  end
end
