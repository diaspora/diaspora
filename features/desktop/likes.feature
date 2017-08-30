@javascript
Feature: Liking posts
  In order to show my appreciation
  As a friendly person
  I want to like their posts

  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "bob@bob.bob" has a public post with text "I like unicorns"
    And I sign in as "alice@alice.alice"

  Scenario: Liking and unliking a post from the stream
    Then I should not have activated notifications for the post
    When I like the post "I like unicorns" in the stream
    Then I should see "Unlike" within ".stream-element .feedback"
    And I should see a ".likes .media" within "#main-stream .stream-element"
    And I should have activated notifications for the post

    When I unlike the post "I like unicorns" in the stream
    Then I should see "Like" within ".stream-element .feedback"
    And I should not see a ".likes .media" within "#main-stream .stream-element"


  Scenario: Liking and unliking a post from a single post page
    When I open the show page of the "I like unicorns" post
    Then I should not have activated notifications for the post in the single post view
    When I click to like the post
    Then I should see a ".count" within "#single-post-interactions"
    And I should have activated notifications for the post in the single post view

    When I click to unlike the post
    Then I should not see a ".count" within "#single-post-interactions"

  Scenario: Someone likes my post
    When I like the post "I like unicorns" in the stream
    And I sign out
    And I sign in as "bob@bob.bob"
    Then I should see a ".likes" within "#main-stream .stream-element"
