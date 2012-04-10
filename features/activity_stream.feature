@javascript
Feature: The activity stream
  Scenario: Sorting
    Given a user with username "bob"
    When I sign in as "bob@bob.bob"

    And I post "A- I like turtles"
    And I post "B- barack obama is your new bicycle"
    And I post "C- barack obama is a square"

    When I go to the activity stream page
    Then "C- barack obama is a square" should be post 1
    And "B- barack obama is your new bicycle" should be post 2
    And "A- I like turtles" should be post 3

    When I like the post "A- I like turtles"
    And I comment "Sassy sawfish" on "C- barack obama is a square"
    And I like the post "B- barack obama is your new bicycle"

    When I go to the activity stream page
    Then "B- barack obama is your new bicycle" should be post 1
    And "C- barack obama is a square" should be post 2
    And "A- I like turtles" should be post 3
