@javascript
Feature: Not safe for work

Scenario: Setting not safe for work
  Given a user named "pr0n king" with email "tommy@pr0n.xxx"
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

Scenario: NSFWs users posts are nsfw
  Given a nsfw user with email "tommy@pr0nking.com"
  And I sign in as "tommy@pr0nking.com"
  And I post "I love 0bj3ction4bl3 c0nt3nt!"
  Then the post "I love 0bj3ction4bl3 c0nt3nt!" should be marked nsfw

#  And I log out
#  And I log in as an office worker
#  And I am folllowing "tommy@pr0n.xxx"
#  Then I should not see "I love 0bj3ction4bl3 c0nt3nt!" in my stream
