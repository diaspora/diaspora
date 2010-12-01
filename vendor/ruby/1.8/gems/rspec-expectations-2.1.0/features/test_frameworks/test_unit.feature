Feature: Test::Unit integration

  RSpec-expectations is a stand-alone gem that can be used without
  the rest of RSpec.  It can easily be used with another test
  framework such as Test::Unit if you like RSpec's should/should_not
  syntax but prefer the test organization of another framework.

  Scenario: Basic Test::Unit usage
    Given a file named "rspec_expectations_test.rb" with:
      """
      require 'test/unit'
      require 'rspec/expectations'

      class RSpecExpectationsTest < Test::Unit::TestCase
        RSpec::Matchers.define :be_an_integer do
          match { |actual| Integer === actual }
        end

        def be_an_int
          RSpec.deprecate(:be_an_int, :be_an_integer)
          be_an_integer
        end

        def test_passing_expectation
          x = 1 + 3
          x.should == 4
        end

        def test_failing_expectation
          array = [1, 2]
          array.should be_empty
        end

        def test_expect_matcher
          expect { @a = 5 }.to change { @a }.from(nil).to(5)
        end

        def test_custom_matcher_and_deprecation_warning
          1.should be_an_int
        end
      end
      """
     When I run "ruby rspec_expectations_test.rb"
     Then the output should contain "4 tests, 0 assertions, 1 failures, 0 errors" or "4 tests, 0 assertions, 0 failures, 1 errors"
      And the output should contain "expected empty? to return true, got false"
      And the output should contain "be_an_int is deprecated"
