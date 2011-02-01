@javascript
Feature: Notifications
  In order to see what is happening
  As a User
  I want to get notifications

Scenario: someone offers to share with me
  Given I am signed in
  And I have one contact request
  And I follow "notifications" in the header
  Then I should see "offered to share with you"