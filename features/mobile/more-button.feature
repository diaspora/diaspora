@javascript @mobile
Feature: posting from the mobile main page
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
      And "bob@bob.bob" has a public post with text "post 1"
      And "bob@bob.bob" has a public post with text "post 2"
      And "bob@bob.bob" has a public post with text "post 3"
      And "bob@bob.bob" has a public post with text "post 4"
      And "bob@bob.bob" has a public post with text "post 5"
      And "bob@bob.bob" has a public post with text "post 6"
      And "bob@bob.bob" has a public post with text "post 7"
      And "bob@bob.bob" has a public post with text "post 8"
      And "bob@bob.bob" has a public post with text "post 9"
      And "bob@bob.bob" has a public post with text "post 10"
      And "bob@bob.bob" has a public post with text "post 11"
      And "bob@bob.bob" has a public post with text "post 12"
      And "bob@bob.bob" has a public post with text "post 13"
      And "bob@bob.bob" has a public post with text "post 14"
      And "bob@bob.bob" has a public post with text "post 15"

      When I go to the stream page
      Then I should see "More"

      When I click on selector ".more-link"
      Then I should see "You have reached the end of the stream."

    Scenario: There are 15 +1 posts
      Given I am on the home page
      And "bob@bob.bob" has a public post with text "post 1"
      And "bob@bob.bob" has a public post with text "post 2"
      And "bob@bob.bob" has a public post with text "post 3"
      And "bob@bob.bob" has a public post with text "post 4"
      And "bob@bob.bob" has a public post with text "post 5"
      And "bob@bob.bob" has a public post with text "post 6"
      And "bob@bob.bob" has a public post with text "post 7"
      And "bob@bob.bob" has a public post with text "post 8"
      And "bob@bob.bob" has a public post with text "post 9"
      And "bob@bob.bob" has a public post with text "post 10"
      And "bob@bob.bob" has a public post with text "post 11"
      And "bob@bob.bob" has a public post with text "post 12"
      And "bob@bob.bob" has a public post with text "post 13"
      And "bob@bob.bob" has a public post with text "post 14"
      And "bob@bob.bob" has a public post with text "post 15"
      And "bob@bob.bob" has a public post with text "post 16"

      When I go to the stream page
      Then I should see "More"

      When I click on selector ".more-link"
      Then I should see "You have reached the end of the stream."
