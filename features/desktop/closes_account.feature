@javascript
Feature: Close account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given I am signed in
    When I go to the users edit page
    And I follow "close_account"
    And I put in my password in "close_account_password" in the modal window
    And I press "close_account_confirm" in the modal window
    And I confirm the alert
    Then I should be on the new user session page

    When I try to sign in manually
    Then I should be on the new user session page
    And I should see a flash message with a warning
