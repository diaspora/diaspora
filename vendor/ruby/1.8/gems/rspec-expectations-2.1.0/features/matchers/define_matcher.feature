Feature: Define matcher

  In order to express my domain clearly in my code examples
  As an RSpec user
  I want a shortcut to define custom matchers

  Scenario: define a matcher with default messages
    Given a file named "matcher_with_default_message_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :be_a_multiple_of do |expected|
        match do |actual|
          actual % expected == 0
        end
      end

      describe 9 do
        it {should be_a_multiple_of(3)}
      end

      describe 9 do
        it {should_not be_a_multiple_of(4)}
      end

      # fail intentionally to generate expected output
      describe 9 do
        it {should be_a_multiple_of(4)}
      end

      # fail intentionally to generate expected output
      describe 9 do
        it {should_not be_a_multiple_of(3)}
      end

      """
    When I run "rspec ./matcher_with_default_message_spec.rb --format documentation"
    Then the exit status should not be 0

    And the output should contain "should be a multiple of 3"
    And the output should contain "should not be a multiple of 4"
    And the output should contain "Failure/Error: it {should be_a_multiple_of(4)}"
    And the output should contain "Failure/Error: it {should_not be_a_multiple_of(3)}"

    And the output should contain "4 examples, 2 failures"
    And the output should contain "expected 9 to be a multiple of 4"
    And the output should contain "expected 9 not to be a multiple of 3"

  Scenario: overriding the failure_message_for_should
    Given a file named "matcher_with_failure_message_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :be_a_multiple_of do |expected|
        match do |actual|
          actual % expected == 0
        end
        failure_message_for_should do |actual|
          "expected that #{actual} would be a multiple of #{expected}"
        end
      end

      # fail intentionally to generate expected output
      describe 9 do
        it {should be_a_multiple_of(4)}
      end
      """
    When I run "rspec ./matcher_with_failure_message_spec.rb"
    Then the exit status should not be 0
    And the stdout should contain "1 example, 1 failure"
    And the stdout should contain "expected that 9 would be a multiple of 4"

  Scenario: overriding the failure_message_for_should_not
    Given a file named "matcher_with_failure_for_message_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :be_a_multiple_of do |expected|
        match do |actual|
          actual % expected == 0
        end
        failure_message_for_should_not do |actual|
          "expected that #{actual} would not be a multiple of #{expected}"
        end
      end

      # fail intentionally to generate expected output
      describe 9 do
        it {should_not be_a_multiple_of(3)}
      end
      """
    When I run "rspec ./matcher_with_failure_for_message_spec.rb"
    Then the exit status should not be 0
    And the stdout should contain "1 example, 1 failure"
    And the stdout should contain "expected that 9 would not be a multiple of 3"

  Scenario: overriding the description
    Given a file named "matcher_overriding_description_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :be_a_multiple_of do |expected|
        match do |actual|
          actual % expected == 0
        end
        description do
          "be multiple of #{expected}"
        end
      end

      describe 9 do
        it {should be_a_multiple_of(3)}
      end

      describe 9 do
        it {should_not be_a_multiple_of(4)}
      end
      """
    When I run "rspec ./matcher_overriding_description_spec.rb --format documentation"
    Then the exit status should be 0
    And the stdout should contain "2 examples, 0 failures"
    And the stdout should contain "should be multiple of 3"
    And the stdout should contain "should not be multiple of 4"

  Scenario: with no args
    Given a file named "matcher_with_no_args_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :have_7_fingers do
        match do |thing|
          thing.fingers.length == 7
        end
      end

      class Thing
        def fingers; (1..7).collect {"finger"}; end
      end

      describe Thing do
        it {should have_7_fingers}
      end
      """
    When I run "rspec ./matcher_with_no_args_spec.rb --format documentation"
    Then the exit status should be 0
    And the stdout should contain "1 example, 0 failures"
    And the stdout should contain "should have 7 fingers"

  Scenario: with multiple args
    Given a file named "matcher_with_multiple_args_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :be_the_sum_of do |a,b,c,d|
        match do |sum|
          a + b + c + d == sum
        end
      end

      describe 10 do
        it {should be_the_sum_of(1,2,3,4)}
      end
      """
    When I run "rspec ./matcher_with_multiple_args_spec.rb --format documentation"
    Then the exit status should be 0
    And the stdout should contain "1 example, 0 failures"
    And the stdout should contain "should be the sum of 1, 2, 3, and 4"

  Scenario: with helper methods
    Given a file named "matcher_with_internal_helper_spec.rb" with:
      """
      require 'rspec/expectations'

      RSpec::Matchers.define :have_same_elements_as do |sample|
        match do |actual|
          similar?(sample, actual)
        end

        def similar?(a, b)
          a.sort == b.sort
        end
      end

      describe "these two arrays" do
        specify "should be similar" do
          [1,2,3].should have_same_elements_as([2,3,1])
        end
      end
      """
    When I run "rspec ./matcher_with_internal_helper_spec.rb"
    Then the exit status should be 0
    And the stdout should contain "1 example, 0 failures"

  Scenario: scoped in a module
    Given a file named "scoped_matcher_spec.rb" with:
      """
      require 'rspec/expectations'

      module MyHelpers
        extend RSpec::Matchers::DSL

        matcher :be_just_like do |expected|
          match {|actual| actual == expected}
        end
      end

      describe "group with MyHelpers" do
        include MyHelpers
        it "has access to the defined matcher" do
          5.should be_just_like(5)
        end
      end

      describe "group without MyHelpers" do
        it "does not have access to the defined matcher" do
          expect do
            5.should be_just_like(5)
          end.to raise_exception
        end
      end
      """

    When I run "rspec ./scoped_matcher_spec.rb"
    Then the stdout should contain "2 examples, 0 failures"

  Scenario: scoped in an example group
    Given a file named "scoped_matcher_spec.rb" with:
      """
      require 'rspec/expectations'

      describe "group with matcher" do
        matcher :be_just_like do |expected|
          match {|actual| actual == expected}
        end

        it "has access to the defined matcher" do
          5.should be_just_like(5)
        end

        describe "nested group" do
          it "has access to the defined matcher" do
            5.should be_just_like(5)
          end
        end

      end

      describe "group without matcher" do
        it "does not have access to the defined matcher" do
          expect do
            5.should be_just_like(5)
          end.to raise_exception
        end
      end
      """

    When I run "rspec scoped_matcher_spec.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: matcher with separate logic for should and should_not
    Given a file named "matcher_with_separate_should_not_logic_spec.rb" with:
      """
      RSpec::Matchers.define :contain do |*expected|
        match_for_should do |actual|
          expected.all? { |e| actual.include?(e) }
        end

        match_for_should_not do |actual|
          expected.none? { |e| actual.include?(e) }
        end
      end

      describe [1, 2, 3] do
        it { should contain(1, 2) }
        it { should_not contain(4, 5, 6) }

        # deliberate failures
        it { should contain(1, 4) }
        it { should_not contain(1, 4) }
      end
      """
    When I run "rspec matcher_with_separate_should_not_logic_spec.rb"
    Then the output should contain all of these:
      | 4 examples, 2 failures                    |
      | expected [1, 2, 3] to contain 1 and 4     |
      | expected [1, 2, 3] not to contain 1 and 4 |

  Scenario: use define_method to create a helper method with access to matcher params
    Given a file named "define_method_spec.rb" with:
      """
      RSpec::Matchers.define :be_a_multiple_of do |expected|
        define_method :is_multiple? do |actual|
          actual % expected == 0
        end
        match { |actual| is_multiple?(actual) }
      end

      describe 9 do
        it { should be_a_multiple_of(3) }
        it { should_not be_a_multiple_of(4) }

        # deliberate failures
        it { should be_a_multiple_of(2) }
        it { should_not be_a_multiple_of(3) }
      end
      """
    When I run "rspec define_method_spec.rb"
    Then the output should contain all of these:
      | 4 examples, 2 failures               |
      | expected 9 to be a multiple of 2     |
      | expected 9 not to be a multiple of 3 |
