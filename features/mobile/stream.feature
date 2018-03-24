@javascript @mobile
Feature: Viewing the main stream mobile page

  Background:
    Given following users exist:
      | username   |
      | alice      |
      | bob        |
    And a user with username "bob" is connected with "alice"
    And "alice@alice.alice" has a public post with text "Hello! I am #newhere"

  Scenario: Show post with correct timestamp
    When I sign in as "bob@bob.bob" on the mobile website
    And I go to the stream page
    Then I should see "Hello! I am #newhere" within ".ltr"
    And I should see "less than a minute ago" within "#main-stream"
