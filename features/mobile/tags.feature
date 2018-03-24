@javascript @mobile
Feature: Interacting with tags

  Background:
    Given following users exist:
      | username   |
      | bob        |
      | alice      |
    And "alice@alice.alice" has a public post with text "Hello! I am #newhere"
    When I sign in as "bob@bob.bob" on the mobile website
    And I visit the mobile search page
    And I fill in the following within "#main":
        | q            | #newhere    |
    And I press "Search"
    Then I should see "Follow #newhere" within ".tag_following_action"

  Scenario: Start and stop following a tag
    When I click on selector ".tag_following_action"
    Then I should see "Stop following #newhere" within ".tag_following_action"
    When I am on the home page
    Then I should see "Hello! I am #newhere"

    When I visit the mobile search page
    And I fill in the following within "#main":
        | q            | #newhere    |
    And I press "Search"
    Then I should see "Stop following #newhere" within ".tag_following_action"

    When I click on selector ".tag_following_action"
    Then I should see "Follow #newhere" within ".tag_following_action"
    When I am on the home page
    Then I should not see "Hello! I am #newhere"

  Scenario: Manage tags
    When I click on selector ".tag_following_action"
    Then I should see "Stop following #newhere" within ".tag_following_action"
    When I am on the manage tag followings page
    Then I should see "#newhere" within "ul.followed_tags"

    When I confirm the alert after I click on selector ".tag_following_action.only-delete"
    Then I should see "You aren't following any tags."
    When I am on the home page
    Then I should not see "Hello! I am #newhere"
