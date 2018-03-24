@javascript @mobile
Feature: using the more button on mobile stream
  As a mobile user
  I want to navigate the stream
  And I want to test the text of the more-button in different environments

  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob" on the mobile website

  Scenario: There are no posts
    Given I am on the home page

    When I go to the stream page
    Then I should see "There are no posts yet."

  Scenario: There are <15 posts
    Given I am on the home page
    And "bob@bob.bob" has a public post with text "post 1"

    When I go to the stream page
    Then I should see "You have reached the end of the stream."

  Scenario: There are 15 posts
    Given I am on the home page
    Given there are 15 public posts from "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "post 1"

    When I go to the stream page
    Then I should see "More"

    When I click on selector ".more-link"
    Then I should see "You have reached the end of the stream."

  Scenario: There are 15 +1 posts
    Given I am on the home page
    Given there are 16 public posts from "bob@bob.bob"

    When I go to the stream page
    Then I should see "More"

    When I click on selector ".more-link"
    Then I should see "You have reached the end of the stream."
