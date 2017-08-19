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
      | carol@carol.carol |

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
    And I confirm the alert after I follow "Reshare"
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
    And "bob@bob.bob" has commented "great post!" on "check this out!"
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "commented on your post"
    And I should have 1 email delivery

  Scenario: unconnected user comments in reply to comment by another user who commented a post of someone who she shares with
    Given "alice@alice.alice" has a public post with text "check this out!"
    And "bob@bob.bob" has commented "great post, alice!" on "check this out!"
    And "carol@carol.carol" has commented "great comment, bob!" on "check this out!"
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    And I should see "also commented on"
    And I should have 3 email delivery


  Scenario: unconnected user comments in reply to my comment to her post
    Given "alice@alice.alice" has a public post with text "check this out!"
    And "carol@carol.carol" has commented "great post, alice!" on "check this out!"
    And "alice@alice.alice" has commented "great comment, carol!" on "check this out!"
    When I sign in as "carol@carol.carol"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    And I should see "also commented on"
    And I should have 2 email delivery

  Scenario: connected user comments in reply to my comment to an unconnected user's post
    Given "alice@alice.alice" has a public post with text "check this out!"
    And a user with email "bob@bob.bob" is connected with "carol@carol.carol"
    And "carol@carol.carol" has commented "great post, alice!" on "check this out!"
    And "bob@bob.bob" has commented "great post!" on "check this out!"
    When I sign in as "carol@carol.carol"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    And I should see "also commented on"
    And I should have 3 email delivery

  Scenario: someone mentioned me in their post
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    Then I should see "mentioned you in the post"
    And I should have 1 email delivery

  Scenario: someone mentioned me in a comment
    Given "alice@alice.alice" has a public post with text "check this out!"
    And "bob@bob.bob" has commented mentioning "alice@alice.alice" on "check this out!"
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    And I should see "mentioned you in a comment"
    And I should have 1 email delivery

  Scenario: I mark a notification as read
    Given a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob
    When I sign in as "bob@bob.bob"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    And I wait for notifications to load
    And I should see a ".unread .unread-toggle .entypo-eye"
    When I click on selector ".unread .unread-toggle .entypo-eye"
    Then I should see a ".read .unread-toggle"

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

  Scenario: show hovercard in notification dropdown from the profile edit page
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    When I sign in as "alice@alice.alice"
    And I go to the edit profile page
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    When I wait for notifications to load
    And I activate the first hovercard in the notification dropdown
    And I press the aspect dropdown
    Then the aspect dropdown should be visible

  Scenario: show hovercard in notification dropdown from the stream
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    When I sign in as "alice@alice.alice"
    And I follow "Notifications" in the header
    Then the notification dropdown should be visible
    When I wait for notifications to load
    And I activate the first hovercard in the notification dropdown
    And I press the aspect dropdown
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
    When I wait for notifications to load
    Then there should be 10 notifications loaded
    When I scroll down on the notifications dropdown
    When I wait for notifications to load
    Then there should be 15 notifications loaded
