@javascript
Feature: public repost
  In order to make Diaspora more viral
  As a User
  I want to reshare my friends post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"


  Scenario: does not show the reshare button on my own posts
    And "bob@bob.bob" has a non public post with text "reshare this!"
    And I sign in as "bob@bob.bob"
    Then I should not see "Reshare" 

  Scenario: does not show a reshare button on other private pots
    And "bob@bob.bob" has a non public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    Then I should not see "Reshare" 

  Scenario: does shows the reshare button on my own posts
    And "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    Then I should see "Reshare" 

  Scenario: shows up on the profile page
    And "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    Then I should see a ".reshared"
    And I am on "alice@alice.alice"'s page
    Then I should see "reshare this!" 
    Then I should see a ".reshared"
    And I should see "Bob" 

  Scenario: shows up on the aspects page
    And "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

    Then I should see a ".reshared"
    And I follow "All Aspects"
    Then I should see "reshare this!" 
    Then I should see a ".reshared"
    And I should see "Bob" 

