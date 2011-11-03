@javascript
Feature: Blocking a user from the stream
  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob


  Scenario: Blocking a user
    When I sign in as "bob@bob.bob"
    And I am on the home page
    And I preemptively confirm the alert
    And I wait for the ajax to finish
    When I click on the first block button
    And I am on the home page
    And I wait for the ajax to finish
    Then I should not see any posts in my stream
