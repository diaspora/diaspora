@javascript
Feature: Viewing my activity on the steam mobile page
  In order to navigate Diaspora*
  As a mobile user
  I want to view my activity stream

  Background:
    Given a user with username "alice"
    And "alice@alice.alice" has a public post with text "Hello! i am #newhere"
    When I sign in as "alice@alice.alice"
    And I toggle the mobile view

  Scenario: Show my activity empty
    When I click on selector "img.my_activity"
    Then I should see "My Activity"
    And I should not see "Hello! i am #newhere"

  Scenario: Show post on my activity
    When I click on selector "a.image_link.like_action.inactive"
    And I wait for the ajax to finish
    And I click on selector "img.my_activity"
    Then I should see "My Activity"
    And I should see "Hello! i am #newhere" within ".ltr"
