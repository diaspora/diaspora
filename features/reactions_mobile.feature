@javascript
Feature: reactions mobile post
  In order to navigate Diaspora*
  As a mobile user
  I want to react to posts

  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When "alice@alice.alice" has posted a status message with a photo
    And I sign in as "bob@bob.bob"
    And I toggle the mobile view

  Scenario: like on a mobile post
    When I should see "0 reactions" within ".show_comments"
    And I click on selector "span.show_comments"
    And I click on selector "a.image_link.like_action.inactive"
    Then I go to the stream page
    And I should see "1 reaction" within ".show_comments"
    And I click on selector "a.show_comments"
    And I should see "1" within ".like_count"

  Scenario: comment and delete a mobile post
    When I click on selector "a.image_link.comment_action.inactive"
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    Then I go to the stream page
    And I should see "1 reaction" within ".show_comments"
    And I click on selector "a.show_comments"
    And I should see "1" within ".comment_count"
    When I click on selector "a.image_link.comment_action.inactive"
    And I click on selector "a.remove"
    And I confirm the alert
    Then I should not see "1 reaction" within ".show_comments"
