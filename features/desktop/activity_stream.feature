@javascript
Feature: The activity stream
  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When "alice@alice.alice" has posted a status message with a photo

  Scenario: delete a comment
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"

    When I go to the activity stream page
    Then I should see "Look at this dog"
    And I should see "is that a poodle?"

    When I am on "alice@alice.alice"'s page
    And I click to delete the first comment
    And I confirm the alert

    And I go to the activity stream page
    Then I should not see "Look at this dog"

  Scenario: unliking a post
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I like the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I unlike the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should not see "Look at this dog"

  Scenario: multiple participations
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I like the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I focus the comment field
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"

    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I unlike the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I click to delete the first comment
    And I confirm the alert

    And I go to the activity stream page
    Then I should not see "Look at this dog"
