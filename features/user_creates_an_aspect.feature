@aspects @javascript
Feature: User creates an aspect
  In order to share with a limited group
  As a User
  I want to create a new aspect

  Background:
    Given I am signed in
    And I follow "Manage" in the header
    And I follow "Add a new aspect"

  Scenario: success
    Given I fill in "Name" with "Dorm Mates" in the modal window
    When I press "Create" in the modal window
    Then I should see "Manage aspects"
    And I should see "Dorm Mates" in the header
    And I should see "Dorm Mates" in the aspect list

  Scenario: I omit the name
    Given I fill in "Name" with "" in the modal window
    When I press "Create" in the modal window
    Then I should see "Manage aspects"
    And I should see "Aspect creation failed."
