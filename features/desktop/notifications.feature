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
    Then I should see "mentioned you in the post"
    And I should have 1 email delivery

  Scenario: filter notifications
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    When I sign in as "bob@bob.bob"
    And I am on the notifications page
    Then I should see "mentioned you in the post"
    When I filter notifications by likes
    Then I should not see "mentioned you in the post"
    When I filter notifications by mentions
    Then I should see "mentioned you in the post"

  Scenario: show aspect dropdown in user hovercard
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    And I active the first hovercard after loading the notifications page 
    When I press the aspect dropdown
    Then the aspect dropdown should be visible

  Scenario: scrollbar shows up when >5 notifications
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has 6 posts mentioning Bob
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then the notification dropdown scrollbar should be visible

  Scenario: dropdown will load more elements when bottom is reached
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has 20 posts mentioning Bob
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then the notification dropdown scrollbar should be visible
    Then there should be 10 notifications loaded
    When I scroll down on the notifications dropdown
    Then I should have scrolled down on the notification dropdown
    And I wait for notifications to load
    Then there should be 15 notifications loaded