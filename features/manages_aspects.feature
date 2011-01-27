@aspects @javascript
Feature: User manages aspects
  In order to share with a limited group
  As a User
  I want to create new aspects

  Scenario: creating an aspect from manage aspects page
    Given I am signed in
    When I follow "Home" in the header
    And I follow "Manage aspects"
    And I follow "+ Add a new aspect"
    And I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Dorm Mates" in the header
    
  Scenario: creating an aspect from homepage
    Given I am signed in
    When I follow "Home" in the header
    And I follow "+" in the header
    And I fill in "Name" with "losers" in the modal window
    And I press "Create" in the modal window
    Then I should see "losers" in the header
