@javascript
Feature: Notifications
  In order to see what is happening
  As a User
  I want to get notifications

  Background:
    Given That following users:
      | email             |
      | bob@bob.bob       |
      | alice@alice.alice |

  Scenario: someone shares with me
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "started sharing with you"
    And I go to the notifications page
    Then I should see "started sharing with you"
    And I should have 1 email delivery

  Scenario: someone re-shares my post
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "check this out!"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I follow "Reshare"
    And I confirm the alert
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "reshared your post"
    And I should have 1 email delivery

  Scenario: someone likes my post
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "check this out!"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I follow "Like"
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "liked your post"
    And I should have 1 email delivery

  Scenario: someone comments on my post
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And "alice@alice.alice" has a public post with text "check this out!"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I focus the comment field
    And I fill in the following:
        | text        | great post!    |
    And I press "Comment"
    Then I should see "less than a minute ago" within ".comment"
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "commented on your post"
    And I should have 1 email delivery

  Scenario: someone mentioned me in their post
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "mentioned you in a post"
    And I should have 1 email delivery
