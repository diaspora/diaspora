@javascript
Feature: Mentions
  As user
  I want to mention another user and have a link to them
  To show people that this person exsists.

  Scenario: A user mentions another user and it displays correctly
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    When I sign in as "alice@alice.alice"
    And I am on the home page
    And I follow "Bob Jones"
    Then I should see "Bob Jones"
