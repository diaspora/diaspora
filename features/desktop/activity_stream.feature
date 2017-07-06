@javascript
Feature: The activity stream
  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has posted a status message with a photo

  Scenario: delete a comment
    Given "bob@bob.bob" has commented "is that a poodle?" on "Look at this dog"
    When I sign in as "bob@bob.bob"
    And I go to the activity stream page
    Then I should see "Look at this dog"
    And I should see "is that a poodle?"

    When I go to the commented stream page
    Then I should see "Look at this dog"
    And I should see "is that a poodle?"

    When I go to the liked stream page
    Then I should not see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I confirm the alert after I click to delete the first comment

    And I go to the activity stream page
    Then I should not see "Look at this dog"

    When I go to the commented stream page
    Then I should not see "Look at this dog"

  Scenario: unliking a post
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I like the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I go to the commented stream page
    Then I should not see "Look at this dog"

    When I go to the liked stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I unlike the post "Look at this dog" in the stream
    And I go to the activity stream page
    Then I should not see "Look at this dog"

    When I go to the liked stream page
    Then I should not see "Look at this dog"
