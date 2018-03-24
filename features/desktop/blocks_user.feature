@javascript
Feature: Blocking a user from the stream
  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    And "alice@alice.alice" has a public post with text "All your base are belong to us!"
    And I sign in as "bob@bob.bob"

  Scenario: Blocking a user
    When I confirm the alert after I click on the first block button
    And I go to the home page
    Then I should not see any posts in my stream

  Scenario: Blocking a user from the profile page
    When I am on "alice@alice.alice"'s page
    And I confirm the alert after I click on the profile block button
    Then I should see "Stop ignoring" within "#unblock_user_button"
    And "All your base are belong to us!" should be post 1
    When I go to the home page
    Then I should not see any posts in my stream
