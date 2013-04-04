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

  Scenario: See hovercard in user name on tag page
    When I am on the tag page for "rockstar"
    And I hover the ".hovercardable"
    Then I should see "#rockstar" within ".footer_container"

  Scenario: See hovercard in user avatar on tag page
    When I am on the tag page for "rockstar"
    And I hover the "img.avatar"
    Then I should see "#rockstar" within ".footer_container"
