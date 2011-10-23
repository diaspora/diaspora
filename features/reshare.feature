@javascript
Feature: public repost
  In order to make Diaspora more viral
  As a User
  I want to reshare my friend's post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"

  Scenario: I don't see the reshare button on my own posts
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And "bob@bob.bob" has a non public post with text "but don't reshare this."
    And I sign in as "bob@bob.bob"
    Then I should not see "Reshare" 

  Scenario: I don't see the reshare button on other people's private pots
    Given "bob@bob.bob" has a non public post with text "don't reshare this."
    And I sign in as "alice@alice.alice"
    Then I should not see "Reshare" 

  Scenario: I see the reshare button on my contact's public posts
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    Then I should see "Reshare"

  Scenario: I don't see the reshare button on other people's reshare of my post
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    And I go to the home page
    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"

    When I go to the destroy user session page
    And I sign in as "bob@bob.bob"
    And I go to the home page
    Then I should see "reshare this!"
    And I should not see "Reshare original"

  Scenario: I don't see the reshare button on my reshare post
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    And I go to the home page
    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"
    And I should not see "Reshare original"

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
    And I wait for the ajax to finish

    When I go to the home page
    Then I should see a ".reshare"
    And I should see "reshare this!"
    And I should see "Bob"

    When I go to the home page
    Then I should see "1 reshare"
