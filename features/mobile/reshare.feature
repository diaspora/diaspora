@javascript @mobile
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
    And a user with email "eve@eve.eve" is connected with "bob@bob.bob"
    Given "bob@bob.bob" has a public post with text "reshare this!"
    And I sign in as "alice@alice.alice" on the mobile website

  Scenario: Resharing a post from a single post page
    And I confirm the alert after I click on selector ".reshare-action.inactive"
    Then I should see a ".reshare-action.active"
    When I go to the stream page
    Then I should see "Reshared via" within ".reshare_via"

  Scenario: Resharing a post from a single post page that is reshared
    Given the post with text "reshare this!" is reshared by "eve@eve.eve"
    And a user with email "alice@alice.alice" is connected with "eve@eve.eve"
    And I confirm the alert after I click on the first selector ".reshare-action.inactive"
    Then I should see a ".reshare-action.active"
    When I go to the stream page
    Then I should see "Reshared via" within ".reshare_via"

  Scenario: Delete original reshared post
    Given "alice@alice.alice" has a public post with text "Don't reshare this!"
    And the post with text "Don't reshare this!" is reshared by "bob@bob.bob"
    When I toggle the mobile view
    And I am on "alice@alice.alice"'s page
    And I click to delete the first post
    And I log out
    And I sign in as "bob@bob.bob" on the mobile website
    Then I should see "Original post deleted by author" within ".reshare"
    And I log out
    And I sign in as "eve@eve.eve" on the mobile website
    And I toggle the mobile view
    Then I should see "Original post deleted by author" within ".reshare"

  Scenario: Not resharing own post
    Given I sign in as "bob@bob.bob" on the mobile website
    Then I should see a ".reshare-action.disabled"
    And I should not see any alert after I click on selector ".reshare-action"
    And I should not see a ".reshare-action.active"
    When I go to the stream page
    Then I should not see a ".reshare_via"
