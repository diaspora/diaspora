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
    And I follow "Bob Jones"
    Then I should see "Bob Jones"

  Scenario: A user mentions another user at the end of a post
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When I sign in as "alice@alice.alice"
    And I expand the publisher
    And I append "@Bob" to the publisher
    And I click on the first user in the mentions dropdown list
    And I press "Share"
    Then I should see "Bob Jones" within ".stream-element"
    When I follow "Bob Jones"
    Then I should see "Bob Jones"

  Scenario: A user tries to mention another user multiple times
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When I sign in as "alice@alice.alice"
    And I expand the publisher
    And I append "@Bob" to the publisher
    Then I should see "Bob Jones" within ".tt-suggestion"
    When I click on the first user in the mentions dropdown list
    When I press the "A" key in the publisher
    And I append "@Bob" to the publisher
    Then I should not see the mentions dropdown list
    When I press "Share"
    Then I should see "Bob Jones" within ".stream-element"

    When I expand the publisher
    And I append "@Bob" to the publisher
    And I click on the first user in the mentions dropdown list
    And I press "Share"
    Then I should see "Bob Jones" within ".stream-element"
    When I follow "Bob Jones"
    Then I should see "Bob Jones"

  Scenario: A user mentions another user in a comment and it displays correctly
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "check this out!"
    And "alice@alice.alice" has commented mentioning "bob@bob.bob" on "check this out!"
    When I sign in as "alice@alice.alice"
    And I follow "Bob Jones"
    Then I should see "Bob Jones"

  Scenario: A user mentions another user in a comment using mention suggestions
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "check this out!"
    When I sign in as "alice@alice.alice"
    Then I should see "check this out!"
    When I focus the comment field
    And I enter "@Bob" in the comment field
    Then I should see "Bob Jones" within ".tt-suggestion"
    When I click on the first user in the mentions dropdown list
    And I press the "A" key in the publisher
    And I append "@Bob" to the publisher
    Then I should not see the mentions dropdown list
    When I press "Comment"
    Then I should see "Bob Jones" within ".comments .comment:last-child"
