@javascript
Feature: Creating a new post
  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob"
    And I trumpet
    And I write "Rectangles are awesome"

  Scenario: Posting a public message
    When I press "Share"
    When I go to "/stream"
    Then I should see "Rectangles are awesome" as the first post in my stream

  Scenario: Posting to Aspects
    When I select "generic" in my aspects dropdown
    And I press "Share"
    Then I should see "Rectangles are awesome" as a limited post in my stream
