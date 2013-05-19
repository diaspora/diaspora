@javascript
Feature: resharing from the mobile
  In order to make Diaspora more viral
  As a mobile user
  I want to reshare my friend's post

  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
      | Eve Doe     | eve@eve.eve       |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice"

  Scenario: Resharing a post from a single post page
    When I toggle the mobile view
    And I preemptively confirm the alert
    And I click on selector "a.image_link.reshare_action.inactive"
    And I wait for the ajax to finish
    Then I go to the stream page
    And I should see "reshared via" within ".reshare_via"

  Scenario: Resharing a post from a single post page that is reshared
    Given the post with text "reshare this!" is reshared by "eve@eve.eve"
    And a user with email "alice@alice.alice" is connected with "eve@eve.eve"
    When I toggle the mobile view
    And I preemptively confirm the alert
    And I click on the first selector "a.image_link.reshare_action.inactive"
    And I wait for the ajax to finish
    Then I go to the stream page
    And I should see "reshared via" within ".reshare_via"

  Scenario: Delete original reshared post
    Given "alice@alice.alice" has a public post with text "Don't reshare this!"
    And the post with text "Don't reshare this!" is reshared by "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I preemptively confirm the alert
    When I click to delete the first post
    And I wait for the ajax to finish
    And I log out
    And I sign in as "bob@bob.bob"
    And I toggle the mobile view
    Then I should see "Original post deleted by author." within ".reshare"
