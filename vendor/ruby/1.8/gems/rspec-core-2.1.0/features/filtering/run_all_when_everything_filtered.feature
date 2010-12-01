Feature: run all when everything filtered

  Use the run_all_when_everything_filtered configuration option to do just
  that.  This works well when paired with an inclusion filter like ":focus =>
  true", as it will run all the examples when none match the inclusion filter.

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run :focus => true
        c.run_all_when_everything_filtered = true
      end
      """

  Scenario: no examples match filter (runs all examples)
    Given a file named "spec/sample_spec.rb" with:
      """
      require "spec_helper"

      describe "group 1" do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run "rspec spec/sample_spec.rb --format doc"
    Then the output should contain "No examples were matched by {:focus=>true}, running all"
    And the output should contain "3 examples, 0 failures"
    And the output should contain:
      """
      group 1
        group 1 example 1
        group 1 example 2

      group 2
        group 2 example 1
      """

