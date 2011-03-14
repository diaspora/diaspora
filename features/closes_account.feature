@javascript
Feature: Close Account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given I am signed in
    When I click on my name in the header
    And I follow "account settings"
    And I click ok in the confirm dialog to appear next
    And I follow "Close Account"
    Then I should be on the home page

    When I go to the new user session page
    And I try to sign in
    Then I should be on the new user session page
    When I wait for the ajax to finish
    Then I should see "Invalid email or password."

  Scenario: post display should not throw error when mention is removed for the user whose account is closed
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When I sign in as "alice@alice.alice"
    And I am on the home page
    And I expand the publisher
    And I fill in "status_message_fake_text" with "Hi, @{Bob Jones; bob_jones@example.org} long time no see"
    And I press "Share"
    And I log out
    Then I sign in as "bob@bob.bob"
    When I click on my name in the header
    And I follow "account settings"
    And I click ok in the confirm dialog to appear next
    And I follow "Close Account"
    Then I sign in as "alice@alice.alice"
    And I am on the home page
    Then I should see "Hi, Bob Jones long time no see"
