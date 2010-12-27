@aspects @javascript
Feature: User manages aspects
  In order to share with a limited group
  As a User
  I want to create new aspects

  Scenario: creating an aspect
    Given I am signed in
    When I follow "Home" in the header
    And I follow "manage aspects"
    And I follow "+ Add a new aspect"
    And I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Dorm Mates" in the header
