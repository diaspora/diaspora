@javascript
Feature: Interacting with tags

  Background:
    Given there is a user "Samuel Beckett" who's tagged "#rockstar"
    And I am signed in
    And I am on the homepage

  Scenario: Searching for a tag
    When I search for "#rockstar"
    Then I should be on the tag page for "rockstar"
    And I should see "Samuel Beckett"

  Scenario: adding a contact from a tag page
    When I search for "#rockstar"
    Then I should see an add contact button

    When I click on the add contact button
    Then I should see the contact dialog
    When I add the person to my first aspect
    And I follow "done editing"
    Then I should not see the contact dialog

    When I search for "#rockstar"
    Then I should not see an add contact button
