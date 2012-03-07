@javascript
Feature: Creating a new post
  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob"

  Scenario: Posting a public message
    When I trumpet
    And I write "Rectangles are awesome"
    And I press "Share"
    When I go to "/stream"
    Then I should see "Rectangles are awesome" as the first post in my stream
