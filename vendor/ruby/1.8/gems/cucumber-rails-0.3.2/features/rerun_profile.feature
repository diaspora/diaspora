@announce
Feature: Rerun profile
  In order to concentrate on failing features
  As a Rails developer working with Cucumber
  I want to rerun only failing features

  Scenario: Rerun
    Given I have created a new Rails 3 app "rails-3-app" with cucumber-rails support
    And a file named "rerun.txt" with:
      """
      features/rerun_test.feature:2
      """
    And a file named "features/rerun_test.feature" with:
      """
      Feature: Rerun test
        Scenario: failing before
          Given fixed now

        Scenario: always passing
          Given passing
      """
    And a file named "features/step_definitions/rerun_steps.rb" with:
      """
      Given /fixed now/ do
        puts "All fixed now"
      end

      Given /passing/ do
        puts "I've always been passing"
      end
      """
    When I successfully run "ruby script/cucumber -p rerun"
    Then it should pass with:
      """
      1 scenario (1 passed)
      1 step (1 passed)
      """
    And the file "rerun.txt" should not contain "features/rerun_test.feature:2"
    
