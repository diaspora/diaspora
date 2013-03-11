@javascript
Feature: Close Account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given I am signed in
    When I go to the users edit page
    And I follow "Close Account"
    And I put in my password in "close_account_password" in the modal window
    And I preemptively confirm the alert
    And I press "Close Account" in the modal window
    Then I should be on the new user session page

    When I try to sign in manually
    Then I should be on the new user session page
    And I should see a flash message containing "Invalid username or password"

  Scenario: post display should not throw error when mention is removed for the user whose account is closed
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob

    Then I sign in as "bob@bob.bob"
    When I go to the users edit page
    And I follow "Close Account"
    And I put in my password in "close_account_password" in the modal window
    And I preemptively confirm the alert
    And I press "Close Account" in the modal window
    Then I sign in as "alice@alice.alice"
    And I am on the home page
    Then I should see "Bob Jones"
