@javascript
Feature: close_account
In order to remove my diaspora account
As a User
I want to close my account




Scenario: close my account
  Given I am signed in
  And I click on my name in the header
  And I follow "account settings"
  And I preemptively confirm the alert
  And I follow "Close Account"
  Then I should be on the home page

