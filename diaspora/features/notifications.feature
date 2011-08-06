@javascript
Feature: Notifications
  In order to see what is happening
  As a User
  I want to get notifications

  Background:
    Given a user with email "bob@bob.bob"
    And a user with email "alice@alice.alice"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my 1st aspect
    And I go to the destroy user session page

  Scenario: someone shares with me
    When I sign in as "alice@alice.alice"
    And I follow "notifications" in the header
    And I wait for the ajax to finish
    Then the notification dropdown should be visible
    Then I should see "started sharing with you"
    When I follow "View all"
    Then I should see "started sharing with you"
