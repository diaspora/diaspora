@javascript
Feature: Interacting with tags

  Background:
    Given a user with username "alice"
    And "alice@alice.alice" has a public post with text "Hello! i am #newhere"
    When I sign in as "alice@alice.alice"
    And I toggle the mobile view

  Scenario: Searching for a tag
    When I visit the mobile search page
    And I fill in the following:
        | q            | #newhere    |
    And I press "Search"
    Then I should see "#newhere" within ".ltr"
