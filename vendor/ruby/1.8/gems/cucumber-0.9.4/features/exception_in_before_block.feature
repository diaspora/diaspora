Feature: Exception in Before Block
  In order to know with confidence that my before blocks have run OK
  As a developer
  I want exceptions raised in Before blocks to be handled gracefully and reported by the formatters

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/^this step works$/) do; end
      """
    And a file named "features/support/env.rb" with:
      """
      class SomeSetupException < Exception; end
      class BadStepException < Exception; end
      Before do
        raise SomeSetupException.new("I cannot even start this scenario")
      end
      """

  Scenario: Handle Exception in standard scenario step and carry on
    Given a file named "features/naughty_step_in_scenario.feature" with:
      """
      Feature: Sample

        Scenario: Run a good step
          Given this step works
      """
    When I run cucumber features
    Then it should fail with
      """
      Feature: Sample

        Scenario: Run a good step # features/naughty_step_in_scenario.feature:3
        I cannot even start this scenario (SomeSetupException)
        ./features/support/env.rb:4:in `Before'
          Given this step works   # features/step_definitions/steps.rb:1

      Failing Scenarios:
      cucumber features/naughty_step_in_scenario.feature:3 # Scenario: Run a good step

      1 scenario (1 failed)
      1 step (1 skipped)

      """

  Scenario: Handle Exception in Before hook for Scenario with Background
    Given a file named "features/naughty_step_in_before.feature" with:
      """
      Feature: Sample

        Background:
          Given this step works

        Scenario: Run a good step
          Given this step works
      """
    When I run cucumber features
    Then it should fail with
      """
      Feature: Sample
      
        Background:             # features/naughty_step_in_before.feature:3
        I cannot even start this scenario (SomeSetupException)
        ./features/support/env.rb:4:in `Before'
          Given this step works # features/step_definitions/steps.rb:1
      
        Scenario: Run a good step # features/naughty_step_in_before.feature:6
          Given this step works   # features/step_definitions/steps.rb:1

      Failing Scenarios:
      cucumber features/naughty_step_in_before.feature:6 # Scenario: Run a good step

      1 scenario (1 failed)
      2 steps (1 skipped, 1 passed)

      """

  Scenario: Handle Exception using the progress format
    Given a file named "features/naughty_step_in_scenario.feature" with:
      """
      Feature: Sample

        Scenario: Run a good step
          Given this step works
      """
    When I run cucumber features --format progress
    Then it should fail with
      """
      F-

      Failing Scenarios:
      cucumber features/naughty_step_in_scenario.feature:3 # Scenario: Run a good step

      1 scenario (1 failed)
      1 step (1 skipped)

      """
