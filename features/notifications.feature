@javascript
Feature: Notifications
  In order to see what is happening
  As a User
  I want to get notifications

Scenario: someone offers to share with me
  Given I am signed in
  And I have one follower
  And I follow "notifications" in the header
  Then I should see "started sharing with you"
