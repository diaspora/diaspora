@javascript
Feature: public repost
  In order to make Diaspora more viral
  As a User
  I want to reshare my friend's post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"

  Scenario: I don't see the reshare button on other people's private posts
    Given "bob@bob.bob" has a non public post with text "don't reshare this."
    And I sign in as "alice@alice.alice"
    Then I should not see "Reshare"

  Scenario: When I reshare, it shows up on my profile page
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"

    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish
    And I wait for 2 seconds

    When I am on "alice@alice.alice"'s page
    Then I should see "reshare this!"
    Then I should see a ".reshare"
    And I should see "Bob"

  Scenario: When I reshare, it shows up in my stream
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    # NOTE(why do we need this to make this work?)
    And I wait for 2 seconds
    And I go to the home page

    And I wait for the ajax to finish
    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"

  Scenario: I can delete a post that has been reshared
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    # NOTE(why do we need this to make this work?)
    And I wait for 2 seconds
    And I go to the home page

    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"

    When I go to the destroy user session page
    And I sign in as "bob@bob.bob"
    And The user deletes their first post
    And I go to the destroy user session page
    And I sign in as "alice@alice.alice"

    When I go to the home page
    Then I should see "Original post deleted by author"

  Scenario: I can see the number of reshares
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I wait for the ajax to finish
    And I preemptively confirm the alert
    And I follow "Reshare"

    # NOTE(why do we need this to make this work?)
    And I wait for 2 seconds
    When I go to the home page

    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"

    # NOTE(why do we need this to make this work?)
    And I wait for 2 seconds
    When I go to the home page
    Then I should see "1 reshare"
