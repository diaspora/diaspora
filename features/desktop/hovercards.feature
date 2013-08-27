@javascript
Feature: Hovercards
  In order to not having to leave the page to view a persons profile
  As a user
  I want to use hovercards

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "public stuff"
    And a user named "Alice" with email "alice@alice.alice"
    And I sign in as "alice@alice.alice"


  Scenario: Hovercards on the main stream
    Given I am on "bob@bob.bob"'s page
    Then I should see "public stuff" within ".stream_element"
    When I activate the first hovercard
    Then I should see a hovercard
    When I deactivate the first hovercard
    Then I should not see a hovercard
