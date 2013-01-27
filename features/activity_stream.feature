@javascript
Feature: The activity stream
  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When "alice@alice.alice" has posted a status message with a photo

  Scenario: Sorting
    When I sign in as "bob@bob.bob"

    And I post "A- I like turtles"
    And I wait for 1 second
    And I post "B- barack obama is your new bicycle"
    And I wait for 1 second
    And I post "C- barack obama is a square"
    And I wait for 1 second

    When I go to the activity stream page
    Then "C- barack obama is a square" should be post 1
    And "B- barack obama is your new bicycle" should be post 2
    And "A- I like turtles" should be post 3

    When I like the post "A- I like turtles"
    And I wait for 1 second
    And I comment "Sassy sawfish" on "C- barack obama is a square"
    And I wait for 1 second
    And I like the post "B- barack obama is your new bicycle"
    And I wait for 1 second

    When I go to the activity stream page
    Then "B- barack obama is your new bicycle" should be post 1
    And "C- barack obama is a square" should be post 2
    And "A- I like turtles" should be post 3

  Scenario: delete a comment
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    And I wait for the ajax to finish

    When I go to the activity stream page
    Then I should see "Look at this dog"
    And I should see "is that a poodle?"

    When I am on "alice@alice.alice"'s page
    And I hover over the ".comment"
    And I preemptively confirm the alert
    And I click to delete the first comment
    And I wait for the ajax to finish

    And I go to the activity stream page
    Then I should not see "Look at this dog"

  Scenario: unliking a post
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I like the post "Look at this dog"
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I unlike the post "Look at this dog"
    And I go to the activity stream page
    Then I should not see "Look at this dog"

  Scenario: multiple participations
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I like the post "Look at this dog"
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"

    When I focus the comment field
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    And I wait for the ajax to finish

    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I unlike the post "Look at this dog"
    And I go to the activity stream page
    Then I should see "Look at this dog"

    When I am on "alice@alice.alice"'s page
    And I hover over the ".comment"
    And I preemptively confirm the alert
    And I click to delete the first comment
    And I wait for the ajax to finish

    And I go to the activity stream page
    Then I should not see "Look at this dog"
