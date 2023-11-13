@javascript @mobile
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
    And I sign in as "bob@bob.bob" on the mobile website

  Scenario: like on a mobile post
    When I click on selector "a.like-action.inactive"
    Then I should see a "a.like-action.active"
    And I should see "1" within ".like-count"
    When I go to the stream page
    Then I should see a "a.like-action.active"
    And I should see "1" within ".like-count"

  Scenario: liking from the profile view
    When I am on "alice@alice.alice"'s page
    And I click on selector "a.like-action.inactive"
    Then I should see a "a.like-action.active"
    And I should see "1" within ".like-count"
    When I go to the stream page
    Then I should see a "a.like-action.active"
    And I should see "1" within ".like-count"

  Scenario: comment and delete a mobile post
    When I click on selector "a.comment-action.inactive"
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    Then I should see "is that a poodle?" within ".comment-container"
    When I go to the stream page
    And I should see "1 comment" within ".show-comments"
    And I should see "1" within ".comment-count"
    When I click on selector "a.show-comments"
    And I click on selector "a.comment-action"
    And I confirm the alert after I click on selector "a.remove"
    Then I should see "0 comments" within ".show-comments"
  
  Scenario: liking and unliking a comment
    When I click on selector "a.comment-action.inactive"
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    Then I should see "is that a poodle?" within ".comment-container"
    When I toggle like on comment with text "is that a poodle?"
    Then I should see a like on comment with text "is that a poodle?"
    When I toggle like on comment with text "is that a poodle?"
    Then I should see an unliked comment with text "is that a poodle?"
