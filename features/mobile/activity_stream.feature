@javascript
Feature: Viewing my activity on the steam mobile page
  In order to navigate Diaspora*
  As a mobile user
  I want to view my activity stream

  Background:
    Given a user with username "alice"
    And "alice@alice.alice" has a public post with text "Hello! i am #newhere"
    When I toggle the mobile view
    And I sign in as "alice@alice.alice"

  Scenario: Show my activity empty
    When I open the drawer
    And I follow "My Activity"
    Then I should see "My Activity"
    And I should not see "Hello! i am #newhere"

  Scenario: Show post on my activity
    When I click on selector "a.image_link.like_action.inactive"
    And I open the drawer
    And I follow "My Activity"
    Then I should see "My Activity"
    And I should see "Hello! i am #newhere" within ".ltr"
