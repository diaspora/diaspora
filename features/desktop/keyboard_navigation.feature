@javascript
Feature: Keyboard navigation
  In order not to have to move my hand to the mouse
  As a user
  I want to be able to navigate the stream by keyboard

  Background:
    Given many posts from alice for bob
    And I sign in as "bob@bob.bob"

  Scenario: navigate downwards
    When I am on the home page
    And I press the "J" key somewhere
    Then post 1 should be highlighted
    And I should have navigated to the highlighted post

    When I press the "J" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

    Given I expand the publisher
    When I press the "J" key in the publisher
    Then post 2 should be highlighted
    And I close the publisher

  Scenario: navigate upwards
    When I am on the home page
    And I scroll to post 3
    When I press the "K" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

  Scenario: expand the comment form in the main stream
    When I am on the home page
    Then the first comment field should be closed
    When I press the "J" key somewhere
    And I press the "C" key somewhere
    Then the first comment field should be open
