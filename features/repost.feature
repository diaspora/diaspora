@javascript
Feature: public repost
  In order to make Diaspora more viral
  As a User
  I want to reshare my friends post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"
    And I preemptively confirm the alert
    And I follow "Reshare"
    And I wait for the ajax to finish

  Scenario: shows up on the profile page
    Then I should see a ".reshared"
    And I am on "alice@alice.alice"'s page
    Then I should see "reshare this!" 
    Then I should see a ".reshared"
    And I should see "Bob" 

  Scenario: shows up on the aspects page
    Then I should see a ".reshared"
    And I follow "All Aspects"
    Then I should see "reshare this!" 
    Then I should see a ".reshared"
    And I should see "Bob" 
