@javascript
Feature: Creating a new post
  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob"
    And I trumpet

  Scenario: Posting a public message
    And I write "Rectangles are awesome"
    When I select "Public" in my aspects dropdown
    When I press "Share"
    When I go to "/stream"
    Then I should see "Rectangles are awesome" as the first post in my stream
    And "Rectangles are awesome" should be a public post in my stream

  Scenario: Posting to Aspects
    And I write "This is super skrunkle"
    When I select "All Aspects" in my aspects dropdown
    And I press "Share"
    When I go to "/stream"
    Then I should see "This is super skrunkle" as the first post in my stream
    Then "This is super skrunkle" should be a limited post in my stream
