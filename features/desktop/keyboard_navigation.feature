@javascript
Feature: Keyboard navigation
  In order not to have to move my hand to the mouse
  As a user
  I want to be able to navigate the stream by keyboard

  Background:
    Given many posts from alice for bob
    And I sign in as "bob@bob.bob"

  Scenario: navigate downwards
    When I press the "J" key somewhere
    Then post 1 should be highlighted
    And I should have navigated to the highlighted post

    When I press the "J" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

    Given I expand the publisher
    When I press the "J" key in the publisher
    Then post 2 should be highlighted
    And I close the publisher

  Scenario: navigate downwards after changing the stream
    When I go to the activity stream page
    And I click on selector "[data-stream='stream'] a"
    Then I should see "Stream" within "#stream-selection .selected"

    When I press the "J" key somewhere
    Then post 1 should be highlighted
    And I should have navigated to the highlighted post

    When I press the "J" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

  Scenario: navigate upwards
    When I press the "J" key somewhere
    And I press the "J" key somewhere
    And I press the "J" key somewhere
    Then post 3 should be highlighted

    When I press the "K" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

  Scenario: expand the comment form in the main stream
    Given the first comment field should be closed
    When I press the "J" key somewhere
    And I press the "C" key somewhere
    Then the first comment field should be open

  Scenario: navigate downwards on a profile page
    When I am on "alice@alice.alice"'s page
    And I press the "J" key somewhere
    Then post 1 should be highlighted
    And I should have navigated to the highlighted post

    When I press the "J" key somewhere
    Then post 2 should be highlighted
    And I should have navigated to the highlighted post

  Scenario: navigate downwards on a small screen
    When I resize my window to 800x600
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
