@javascript
Feature: Not safe for work

Scenario: Setting not safe for work
  Given following users exist:
    | username    | email             | 
    | pr0n king   | tommy@pr0n.xxx    |
  And I sign in as "tommy@pr0n.xxx"
  When I go to the edit profile page
  And I should see the "you are safe for work" message
  And I mark myself as not safe for work
  And I submit the form
  Then I should be on the edit profile page
  And I should see the "you are nsfw" message
  When I mark myself as safe for work
  And I submit the form
  Then I should see the "you are safe for work" message

Scenario: Toggling nsfw state
  #Nsfw users posts are marked nsfw
  Given a nsfw user with email "tommy@pr0nking.com"
  And a user with email "laura@officeworkers.com"
  And a user with email "laura@officeworkers.com" is connected with "tommy@pr0nking.com"
  When I sign in as "tommy@pr0nking.com"
  And I post "I love 0bj3ction4bl3 c0nt3nt!"
  And I post "Sexy Senators Gone Wild!"
  Then I should have 2 nsfw posts

  #toggling global nsfw state
  When I log out
  And I sign in as "laura@officeworkers.com"
  Then I should not see "I love 0bj3ction4bl3 c0nt3nt!"
  When I toggle nsfw posts
  Then I should see "I love 0bj3ction4bl3 c0nt3nt!" and "Sexy Senators Gone Wild!"

  #cookies
  #When I refresh the page
  #Then I should see "I love 0bj3ction4bl3 c0nt3nt!"
  #And I should see "Sexy Senators Gone Wild!"

  #hiding
  When I toggle nsfw posts
  Then I should not see "I love 0bj3ction4bl3 c0nt3nt!" and "Sexy Senators Gone Wild!"

Scenario: Resharing an nsfw post
  Given a nsfw user with email "tommy@pr0nking.com"
  And a user with email "laura@officeworkers.com"
  And a user with email "laura@officeworkers.com" is connected with "tommy@pr0nking.com"
  And "tommy@pr0nking.com" has a public post with text "Sexy Senators Gone Wild!"
  And I sign in as "laura@officeworkers.com"
  And I toggle nsfw posts
  And I preemptively confirm the alert
  And I follow "Reshare"
  And I wait for 2 seconds
  And I wait for the ajax to finish
  And I go to the home page
  #if this is failing on travis throw a random wait in here :/
  And I wait for the ajax to finish
  Then I should not see "Sexy Senators Gone Wild!"
  And I should have 2 nsfw posts
