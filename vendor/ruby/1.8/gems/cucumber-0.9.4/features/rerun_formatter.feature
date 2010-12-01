Feature: Rerun Debugger
  In order to save time
  I want to run *only* failed, pending and missing features from previous runs
  (with the help of a smart cucumber.yml)

  Background:
    Given a standard Cucumber project directory structure

  Scenario: title
    Given a file named "features/sample.feature" with:
      """
      Feature: Rerun

        Scenario: Failing
          Given failing

        Scenario: Missing
          Given missing

        Scenario: Pending
          Given pending

        Scenario: Passing
          Given passing
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /failing/ do
        raise 'FAIL'
      end

      Given /pending/ do
        pending
      end

      Given /passing/ do
      end
      """

    When I run cucumber -f rerun features/sample.feature
    Then it should fail with
      """
      features/sample.feature:3:6:9

      """
