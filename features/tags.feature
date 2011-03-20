@javascript
Feature: Interacting with tags

  Scenario: Searching for a tag
    Given I am signed in
    And I am on the homepage
    And I search for "#rockstar"
    Then I should be on the tag page for "rockstar"