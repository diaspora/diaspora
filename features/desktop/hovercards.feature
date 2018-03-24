@javascript
Feature: Hovercards
  In order to not having to leave the page to view a persons profile
  As a user
  I want to use hovercards

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "public stuff #hashtag"
    And a user named "Alice" with email "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "alice public stuff"
    And the post with text "public stuff #hashtag" is reshared by "alice@alice.alice"
    And the post with text "alice public stuff" is reshared by "bob@bob.bob"

  Scenario: Hovercards on the main stream
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "public stuff" within ".stream-element"
    When I activate the first hovercard
    Then I should see a hovercard
    When I deactivate the first hovercard
    Then I should not see a hovercard

  Scenario: Hovercards on the main stream in reshares
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "Alice" within "#main-stream"
    When I hover "Alice" within "#main-stream"
    Then I should not see a hovercard
    When I am on "alice@alice.alice"'s page
    Then I should see "Bob Jones" within "#main-stream"
    When I hover "Bob Jones" within "#main-stream"
    Then I should see a hovercard

  Scenario: Hovercards on the tag stream as a logged out user
    Given I am on the tag page for "hashtag"
    Then I should see "public stuff" within ".stream-element"
    When I activate the first hovercard
    Then I should see a hovercard
    When I deactivate the first hovercard
    Then I should not see a hovercard

  Scenario: Hovercards contain profile tags
    Given a user with email "bob@bob.bob" is tagged "#first #second"
    And I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "public stuff" within ".stream-element"
    When I activate the first hovercard
    Then I should see a hovercard
    And I should see "#first" hashtag in the hovercard
    And I should see "#second" hashtag in the hovercard
