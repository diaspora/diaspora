@aspects @javascript
Feature: User creates an aspect
  In order to share with a limited group
  As a User
  I want to create a new aspect

  Scenario: success
    Given I am signed in
    And I follow "Manage" in the header
    And I follow "Add a new aspect"
    When I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Manage Aspects"
    And I should see "Dorm Mates" in the header
    And I should see "Dorm Mates" in the aspect list

  Scenario: I omit the name
    Given I am signed in
    And I follow "Manage" in the header
    And I follow "Add a new aspect"
    When I press "Create" in the modal window
    Then I should see "Manage Aspects"
    And I should see "Aspect creation failed."
