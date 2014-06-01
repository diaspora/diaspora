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

  Scenario: post display should not throw error when mention is removed for the user whose account is closed
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And Alice has a post mentioning Bob

    Then I sign in as "bob@bob.bob"
    When I go to the users edit page
    And I follow "close_account"
    And I put in my password in "close_account_password" in the modal window
    And I press "close_account_confirm" in the modal window
    And I confirm the alert
    Then I sign in as "alice@alice.alice"
    #TODO: find out why the automatic login here doesn't work anymore
    And I try to sign in manually
    And I am on the home page
    Then I should see "Bob Jones"
