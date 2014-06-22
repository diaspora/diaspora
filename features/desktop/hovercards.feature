@javascript
Feature: Hovercards
  In order to not having to leave the page to view a persons profile
  As a user
  I want to use hovercards

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "public stuff"
    And a user named "Alice" with email "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "alice public stuff"
    And the post with text "public stuff" is reshared by "alice@alice.alice"
    And the post with text "alice public stuff" is reshared by "bob@bob.bob"
    And I sign in as "alice@alice.alice"

  Scenario: Hovercards on the main stream
    Given I am on "bob@bob.bob"'s page
    Then I should see "public stuff" within ".stream_element"
    When I activate the first hovercard
    Then I should see a hovercard
    When I deactivate the first hovercard
    Then I should not see a hovercard

  Scenario: Hovercards on the main stream in reshares
    Given I am on "bob@bob.bob"'s page
    Then I should see "Alice" within "#main_stream"
    When I hover "Alice" within "#main_stream"
    Then I should not see a hovercard
    When I am on "alice@alice.alice"'s page
    Then I should see "Bob Jones" within "#main_stream"
    When I hover "Bob Jones" within "#main_stream"
    Then I should see a hovercard
