@javascript
Feature: Close account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given I am signed in
    When I go to the edit user page
    And I click on selector "#close_account"
    Then I should see a modal
    And I should see "Hey, please don’t go!" within "#closeAccountModal"
    When I put in my password in "close_account_password"
    And I confirm the alert after I press "Close account" in the modal
    Then I should be on the new user session page

    When I try to sign in manually
    Then I should be on the new user session page
    And I should see a flash message with a warning
