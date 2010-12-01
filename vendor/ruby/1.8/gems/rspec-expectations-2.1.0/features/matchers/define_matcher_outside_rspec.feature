Feature: Define matcher outside rspec

  In order to express my domain clearly in my code examples
  As a non-rspec user
  I want a shortcut to define custom matchers

  Scenario: define a matcher with default messages
    Given a file named "test_multiples.rb" with:
      """
      require "rspec/expectations"
      require "test/unit"
      
      RSpec::Matchers.define :be_a_multiple_of do |expected|
        match do |actual|
          actual % expected == 0
        end
      end
      
      class Test::Unit::TestCase
        include RSpec::Matchers
      end
      
      class TestMultiples < Test::Unit::TestCase
      
        def test_9_should_be_a_multiple_of_3
          9.should be_a_multiple_of(3)
        end

        def test_9_should_be_a_multiple_of_4
          9.should be_a_multiple_of(4)
        end
        
      end
      """
    When I run "ruby test_multiples.rb"
    Then the exit status should not be 0 
    And the output should contain "expected 9 to be a multiple of 4"
    And the output should contain "2 tests, 0 assertions, 0 failures, 1 errors"
