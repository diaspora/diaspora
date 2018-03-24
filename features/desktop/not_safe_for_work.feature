@javascript
Feature: Not safe for work

Scenario: Setting not safe for work
  Given following users exist:
    | username    | email             |
    | pr0n king   | tommy@pr0n.xxx    |
  And I sign in as "tommy@pr0n.xxx"
  When I go to the edit profile page
  And I mark myself as not safe for work
  And I submit the form
  Then I should be on the edit profile page
  And the "profile[nsfw]" checkbox should be checked
  When I go to the edit profile page
  And I mark myself as safe for work
  And I submit the form
  Then I should be on the edit profile page
  And the "profile[nsfw]" checkbox should not be checked

Scenario: Toggling nsfw state
  #Nsfw users posts are marked nsfw
  Given a nsfw user with email "tommy@pr0nking.com"
  And a user with email "laura@officeworkers.com"
  And a user with email "laura@officeworkers.com" is connected with "tommy@pr0nking.com"
  And "tommy@pr0nking.com" has a public post with text "I love 0bj3ction4bl3 c0nt3nt!"
  And "tommy@pr0nking.com" has a public post with text "Sexy Senators Gone Wild!"

  #toggling global nsfw state
  When I sign in as "laura@officeworkers.com"
  Then I should not see "I love 0bj3ction4bl3 c0nt3nt!"
  When I toggle nsfw posts
  Then I should see "I love 0bj3ction4bl3 c0nt3nt!" and "Sexy Senators Gone Wild!"

  #hiding
  When I toggle nsfw posts
  Then I should not see "I love 0bj3ction4bl3 c0nt3nt!" and "Sexy Senators Gone Wild!"

Scenario: Resharing a nsfw post
  Given a nsfw user with email "tommy@pr0nking.com"
  And a user with email "laura@officeworkers.com"
  And a user with email "laura@officeworkers.com" is connected with "tommy@pr0nking.com"
  And "tommy@pr0nking.com" has a public post with text "Sexy Senators Gone Wild!"
  And I sign in as "laura@officeworkers.com"
  And I toggle nsfw posts
  And I confirm the alert after I follow "Reshare"
  And I go to the home page
  Then I should not see "Sexy Senators Gone Wild!"
  And I should have 2 nsfw posts
