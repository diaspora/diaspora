@javascript @mobile
Feature: Viewing my activity on the steam mobile page
  In order to navigate Diaspora*
  As a mobile user
  I want to view my activity stream

  Background:
    Given a user with username "alice"
    And "alice@alice.alice" has a public post with text "Hello! I am #newhere"
    And I sign in as "alice@alice.alice" on the mobile website

  Scenario: Show my activity empty
    When I go to the activity stream page
    Then I should see "My activity" within "#main"
    And I should not see "Hello! I am #newhere"

  Scenario: Show post on my activity
    When I click on selector "a.like-action.inactive"
    And I go to the activity stream page
    Then I should see "My activity" within "#main"
    And I should see "Hello! I am #newhere" within ".ltr"
