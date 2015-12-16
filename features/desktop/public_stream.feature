@javascript
Feature: The public stream
  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |
      | Bob Jones   | bob@bob.bob       |
      | Eve Doe     | eve@eve.eve       |
    And a user with email "alice@alice.alice" is connected with "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "Bob’s public post"
    And "bob@bob.bob" has a non public post with text "Bob’s private post"
    And "eve@eve.eve" has a public post with text "Eve’s public post"
  
  Scenario: seeing public posts of someone you don't follow
    When I sign in as "alice@alice.alice"
    Then I should not see "Eve’s public post"
    When I am on the public stream page
    Then I should see "Eve’s public post"

  Scenario: seeing public posts of someone you follow
    When I sign in as "alice@alice.alice"
    Then I should see "Bob’s public post"
    When I am on the public stream page
    Then I should see "Bob’s public post"

  Scenario: not seeing private posts of someone you follow
    When I sign in as "alice@alice.alice"
    Then I should see "Bob’s private post"
    When I am on the public stream page
    Then I should not see "Bob’s private post"
