@javascript
Feature: Blocking a user from the stream
  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    And I sign in as "bob@bob.bob"


  Scenario: Blocking a user
    When I am on the home page
    When I click on the first block button
    And I confirm the alert
    And I am on the home page
    Then I should not see any posts in my stream

  Scenario: Blocking a user from the profile page
    When I am on "alice@alice.alice"'s page
    When I click on the profile block button
    And I confirm the alert
    Then I should not see any posts in my stream
