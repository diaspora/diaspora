@javascript
Feature: The public stream
  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |
      | Bob Jones   | bob@bob.bob       |

    And "bob@bob.bob" has a public post with text "Bob’s public post"

  Scenario: seeing public posts
    When I sign in as "alice@alice.alice"
    And I am on the public stream page
    Then I should see "Bob’s public post"

  Scenario: seeing public posts as a logged out user
    When I am on the public stream page
    Then I should see "Bob’s public post"
