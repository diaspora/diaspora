@javascript
Feature: (web+)diaspora:// links resolve
  In order to open diaspora posts on my pod from external websites
  As a user
  I want external links to be resolved to local pod paths

  Background:
    Given following user exists:
      | username | email             |
      | Alice    | alice@alice.alice |
    And "alice@alice.alice" has a public post with text "This is a post accessed by an external link"

  Scenario: Resolving web+diaspora:// link
    When I open an external link to the first post of "alice@alice.alice"
    Then I should see "This is a post accessed by an external link"
