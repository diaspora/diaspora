Feature: fail fast

  Use the fail_fast option to tell RSpec to abort the run on first failure:

      RSpec.configure {|c| c.fail_fast = true}

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """
      RSpec.configure {|c| c.fail_fast = true}
      """

  Scenario: fail_fast with no failures (runs all examples)
    Given a file named "spec/example_spec.rb" with:
      """
      describe "something" do
        it "passes" do
        end

        it "passes too" do
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the examples should all pass

  Scenario: fail_fast with first example failing (only runs the one example)
    Given a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"
      describe "something" do
        it "fails" do
          fail
        end

        it "passes" do
        end
      end
      """
    When I run `rspec spec/example_spec.rb -fd`
    Then the output should contain "1 example, 1 failure"

  Scenario: fail_fast with multiple files, second example failing (only runs the first two examples)
    Given a file named "spec/example_1_spec.rb" with:
      """
      require "spec_helper"
      describe "something" do
        it "passes" do
        end

        it "fails" do
          fail
        end
      end

      describe "something else" do
        it "fails" do
          fail
        end
      end
      """
    And a file named "spec/example_2_spec.rb" with:
      """
      require "spec_helper"
      describe "something" do
        it "passes" do
        end
      end

      describe "something else" do
        it "fails" do
          fail
        end
      end
      """
    When I run `rspec spec`
    Then the output should contain "2 examples, 1 failure"
