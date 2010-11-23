@javascript @wip
Feature: posting a message

  Scenario: public messages
    Given I am signed in
    And I fill in "Post a message to all" with "ohai"
    And I wait for the "Share" button to appear
    And I press "Share"
    Then I should see "ohai" in the main content area