@screenshots @javascript
Feature: layout reference screenshots
  In order to be able to compare style and layout changes
  As a developer
  I want to be able to look at before/after screenshots

  Background:
    Given following users exist:
      | username       | email             |
      | B Robertson   | bob@bob.bob       |
      | A Aronsdottir | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "bob@bob.bob" has a public post with text "this is a test post!"
    And Alice has a post mentioning Bob
    And "alice@alice.alice" has a public post with text "i am using a #tag"

  @reference-screenshots
  Scenario: take the reference screenshots
    Given the reference screenshot directory is used
    When I take the screenshots while logged out

    And I sign in as "alice@alice.alice"
    Then I take the screenshots while logged in

  @comparison-screenshots
  Scenario: take the comparison screenshots
    Given the comparison screenshot directory is used
    When I take the screenshots while logged out

    And I sign in as "alice@alice.alice"
    Then I take the screenshots while logged in
