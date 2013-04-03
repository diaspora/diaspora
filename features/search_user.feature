@javascript
Feature: Search user feature

  Background:
    Given there is a user "Samuel Beckett" who's tagged "#carmendemairena"
    And I am signed in
    And I am on the homepage

  Scenario: Searching for a user
    When I search for "Samuel"
    And I hover the ".hovercardable"
    Then I should see "Samuel Becket"
    And I should see "#carmendemairena" within ".footer_container"

  Scenario: See hovercard in user avatar on tag page
    When I search for "Samuel"
    And I hover the "img.avatar"
    Then I should see "#carmendemairena" within ".footer_container"
